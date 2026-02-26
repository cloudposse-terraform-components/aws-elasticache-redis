locals {
  enabled = module.this.enabled

  auth_token_enabled = local.enabled && var.cluster_attributes.transit_encryption_enabled && var.cluster_attributes.auth_token_enabled

  ssm_path_auth_token = local.auth_token_enabled ? format("/%s/%s/%s", "elasticache-redis", var.cluster_name, "auth_token") : null

  auth_token = local.auth_token_enabled ? one(random_password.auth_token[*].result) : null
}

module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "2.0.0"

  name = var.cluster_name

  additional_security_group_rules      = var.cluster_attributes.additional_security_group_rules
  allow_all_egress                     = var.cluster_attributes.allow_all_egress
  allowed_security_group_ids           = var.cluster_attributes.allowed_security_groups
  apply_immediately                    = var.cluster_attributes.apply_immediately
  at_rest_encryption_enabled           = var.cluster_attributes.at_rest_encryption_enabled
  auth_token                           = local.auth_token
  auth_token_update_strategy           = var.cluster_attributes.auth_token_update_strategy
  auto_minor_version_upgrade           = var.cluster_attributes.auto_minor_version_upgrade
  automatic_failover_enabled           = var.cluster_attributes.automatic_failover_enabled
  availability_zones                   = var.cluster_attributes.availability_zones
  multi_az_enabled                     = var.cluster_attributes.multi_az_enabled
  cluster_mode_enabled                 = var.num_shards > 0
  cluster_mode_num_node_groups         = var.num_shards
  cluster_mode_replicas_per_node_group = var.replicas_per_shard
  cluster_size                         = var.num_replicas
  data_tiering_enabled                 = var.cluster_attributes.data_tiering_enabled
  description                          = var.description
  dns_subdomain                        = var.dns_subdomain
  elasticache_subnet_group_name        = var.cluster_attributes.elasticache_subnet_group_name
  engine                               = var.engine
  engine_version                       = var.engine_version
  family                               = var.cluster_attributes.family
  final_snapshot_identifier            = var.final_snapshot_identifier
  global_replication_group_id          = var.cluster_attributes.global_replication_group_id
  instance_type                        = var.instance_type
  kms_key_id                           = var.cluster_attributes.kms_key_id
  log_delivery_configuration           = var.cluster_attributes.log_delivery_configuration
  create_parameter_group               = var.create_parameter_group
  parameter                            = var.parameters
  parameter_group_description          = var.cluster_attributes.parameter_group_description
  parameter_group_name                 = var.parameter_group_name
  port                                 = var.cluster_attributes.port
  replication_group_id                 = var.replication_group_id
  network_type                         = var.cluster_attributes.network_type
  notification_topic_arn               = var.cluster_attributes.notification_topic_arn
  alarm_cpu_threshold_percent          = var.cluster_attributes.alarm_cpu_threshold_percent
  alarm_memory_threshold_bytes         = var.cluster_attributes.alarm_memory_threshold_bytes
  alarm_actions                        = var.cluster_attributes.alarm_actions
  ok_actions                           = var.cluster_attributes.ok_actions
  snapshot_arns                        = var.snapshot_arns
  snapshot_name                        = var.snapshot_name
  snapshot_retention_limit             = var.cluster_attributes.snapshot_retention_limit
  snapshot_window                      = var.cluster_attributes.snapshot_window
  maintenance_window                   = var.cluster_attributes.maintenance_window
  subnets                              = var.cluster_attributes.subnets
  transit_encryption_enabled           = var.cluster_attributes.transit_encryption_enabled
  transit_encryption_mode              = var.cluster_attributes.transit_encryption_mode
  user_group_ids                       = var.cluster_attributes.user_group_ids
  vpc_id                               = var.cluster_attributes.vpc_id
  zone_id                              = var.cluster_attributes.zone_id

  serverless_enabled                  = var.cluster_attributes.serverless_enabled
  serverless_major_engine_version     = var.cluster_attributes.serverless_major_engine_version
  serverless_snapshot_time            = var.cluster_attributes.serverless_snapshot_time
  serverless_user_group_id            = var.cluster_attributes.serverless_user_group_id
  serverless_cache_usage_limits       = var.cluster_attributes.serverless_cache_usage_limits
  serverless_snapshot_arns_to_restore = var.cluster_attributes.serverless_snapshot_arns_to_restore

  context = module.this.context
}

# https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/auth.html
resource "random_password" "auth_token" {
  count = local.auth_token_enabled ? 1 : 0

  # min 16, max 128
  length  = 128
  special = true

  # Original chars
  # override_special = "!&#$^<>-"
  # Removed $ and ! to avoid issues with environment variables
  override_special = "#^-"

  min_upper   = 3
  min_lower   = 3
  min_numeric = 3
  min_special = 3

  keepers = {
    cluster_name = var.cluster_name
  }
}

module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  enabled = local.auth_token_enabled

  kms_arn = var.kms_alias_name_ssm

  parameter_write = [
    {
      name        = local.ssm_path_auth_token
      value       = local.auth_token
      description = "Redis auth_token"
      type        = "SecureString"
      overwrite   = true
    },
  ]

  context = module.this.context
}
