locals {
  enabled = module.this.enabled

  eks_security_group_enabled = local.enabled && var.eks_security_group_enabled

  allowed_cidr_blocks = concat(
    var.allow_ingress_from_this_vpc ? [module.vpc.outputs.vpc_cidr] : [],
    var.ingress_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )

  allowed_security_groups = [
    for eks in module.eks :
    eks.outputs.eks_cluster_managed_security_group_id
  ]

  sg_rules_ingress = length(local.allowed_cidr_blocks) == 0 ? [] : [
    {
      key         = "in"
      type        = "ingress"
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = local.allowed_cidr_blocks
      description = var.ingress_cidr_blocks_rule_description
    }
  ]

  sg_rules_egress = var.allow_all_egress ? [] : [
    {
      key         = "out"
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.egress_cidr_blocks
      description = var.egress_cidr_blocks_rule_description
    }
  ]

  additional_security_group_rules = concat(local.sg_rules_ingress, local.sg_rules_egress, var.additional_security_group_rules)

  # global attributes
  cluster_attributes = {
    vpc_id             = module.vpc.outputs.vpc_id
    subnets            = module.vpc.outputs.private_subnet_ids
    availability_zones = var.availability_zones
    multi_az_enabled   = var.multi_az_enabled

    allowed_security_groups         = local.allowed_security_groups
    additional_security_group_rules = local.additional_security_group_rules
    allow_all_egress                = var.allow_all_egress

    zone_id                          = module.dns_delegated.outputs.default_dns_zone_id
    family                           = var.family
    port                             = var.port
    at_rest_encryption_enabled       = var.at_rest_encryption_enabled
    transit_encryption_enabled       = var.transit_encryption_enabled
    transit_encryption_mode          = var.transit_encryption_mode
    apply_immediately                = var.apply_immediately
    automatic_failover_enabled       = var.automatic_failover_enabled
    auto_minor_version_upgrade       = var.auto_minor_version_upgrade
    cloudwatch_metric_alarms_enabled = var.cloudwatch_metric_alarms_enabled
    auth_token_enabled               = var.auth_token_enabled
    snapshot_retention_limit         = var.snapshot_retention_limit
    snapshot_window                  = var.snapshot_window
    maintenance_window               = var.maintenance_window

    elasticache_subnet_group_name = var.elasticache_subnet_group_name
    network_type                  = var.network_type
    notification_topic_arn        = var.notification_topic_arn
    alarm_cpu_threshold_percent   = var.alarm_cpu_threshold_percent
    alarm_memory_threshold_bytes  = var.alarm_memory_threshold_bytes
    alarm_actions                 = var.alarm_actions
    ok_actions                    = var.ok_actions
    data_tiering_enabled          = var.data_tiering_enabled
    auth_token_update_strategy    = var.auth_token_update_strategy
    kms_key_id                    = var.kms_key_id
    parameter_group_description   = var.parameter_group_description
    log_delivery_configuration    = var.log_delivery_configuration
    user_group_ids                = var.user_group_ids
    global_replication_group_id   = var.global_replication_group_id

    serverless_enabled                  = var.serverless_enabled
    serverless_major_engine_version     = var.serverless_major_engine_version
    serverless_snapshot_time            = var.serverless_snapshot_time
    serverless_user_group_id            = var.serverless_user_group_id
    serverless_cache_usage_limits       = var.serverless_cache_usage_limits
    serverless_snapshot_arns_to_restore = var.serverless_snapshot_arns_to_restore
  }

  clusters = module.redis_clusters
}

module "redis_clusters" {
  source = "./modules/redis_cluster"

  for_each = var.redis_clusters

  cluster_name  = lookup(each.value, "cluster_name", replace(each.key, "_", "-"))
  dns_subdomain = lookup(each.value, "dns_subdomain", join(".", [lookup(each.value, "cluster_name", replace(each.key, "_", "-")), module.this.environment]))

  instance_type          = each.value.instance_type
  num_replicas           = lookup(each.value, "num_replicas", var.num_replicas)
  num_shards             = lookup(each.value, "num_shards", var.num_shards)
  replicas_per_shard     = lookup(each.value, "replicas_per_shard", var.replicas_per_shard)
  engine                 = lookup(each.value, "engine", var.engine)
  engine_version         = each.value.engine_version
  create_parameter_group = lookup(each.value, "create_parameter_group", var.create_parameter_group)
  parameters             = lookup(each.value, "parameters", var.parameters)
  parameter_group_name   = lookup(each.value, "parameter_group_name", var.parameter_group_name)
  cluster_attributes     = local.cluster_attributes

  snapshot_name             = lookup(each.value, "snapshot_name", var.snapshot_name)
  snapshot_arns             = lookup(each.value, "snapshot_arns", var.snapshot_arns)
  final_snapshot_identifier = lookup(each.value, "final_snapshot_identifier", var.final_snapshot_identifier)
  replication_group_id      = lookup(each.value, "replication_group_id", var.replication_group_id)
  description               = lookup(each.value, "description", var.description)

  context = module.this.context
}
