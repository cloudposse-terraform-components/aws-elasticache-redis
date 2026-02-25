variable "region" {
  type        = string
  description = "AWS region"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
  default     = []
}

variable "multi_az_enabled" {
  type        = bool
  default     = false
  description = "Multi AZ (Automatic Failover must also be enabled.  If Cluster Mode is enabled, Multi AZ is on by default, and this setting is ignored)"
}

variable "num_replicas" {
  type        = number
  default     = 1
  description = "Default number of replicas in the replica set for all Redis clusters. Can be overridden per cluster in redis_clusters."
}

variable "num_shards" {
  type        = number
  default     = 0
  description = "Default number of shards (node groups) for Redis clusters. Value > 0 enables cluster mode. Can be overridden per cluster in redis_clusters."

  validation {
    condition     = var.num_shards >= 0 && var.num_shards <= 500
    error_message = "num_shards must be between 0 and 500; use 0 to disable cluster mode."
  }
}

variable "replicas_per_shard" {
  type        = number
  default     = 0
  description = "Default number of replica nodes per shard for Redis clusters. Valid values are 0 to 5. Can be overridden per cluster in redis_clusters."

  validation {
    condition     = var.replicas_per_shard >= 0 && var.replicas_per_shard <= 5
    error_message = "replicas_per_shard must be between 0 and 5."
  }
}

variable "engine" {
  type        = string
  default     = "redis"
  description = "Default cache engine for all Redis clusters. Valid values: `redis` or `valkey`. Can be overridden per cluster in redis_clusters."

  validation {
    condition     = contains(["redis", "valkey"], var.engine)
    error_message = "engine must be either 'redis' or 'valkey'."
  }
}

variable "create_parameter_group" {
  type        = bool
  default     = true
  description = "Default setting for whether a new parameter group should be created for all Redis clusters. Set to false to use an existing parameter group. Can be overridden per cluster in redis_clusters."
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "Default list of Redis parameters to configure for all clusters. Can be overridden per cluster in redis_clusters."
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Default override parameter group name for all Redis clusters. Can be overridden per cluster in redis_clusters."
}

variable "snapshot_name" {
  type        = string
  default     = null
  description = "Default name of a snapshot to restore into all new Redis clusters. Changing this forces a new resource. Can be overridden per cluster in redis_clusters."
}

variable "snapshot_arns" {
  type        = list(string)
  default     = []
  description = "Default list of ARNs of Redis RDB snapshot files in S3 to restore into all new clusters. Can be overridden per cluster in redis_clusters."
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "Default name of the final snapshot to create before deleting all Redis clusters. If null, no final snapshot is created. Can be overridden per cluster in redis_clusters."
}

variable "replication_group_id" {
  type        = string
  default     = ""
  description = "Default replication group ID for all Redis clusters. Must be 1-20 alphanumeric characters or hyphens, start with a letter, and not end with or contain consecutive hyphens. Can be overridden per cluster in redis_clusters."
}

variable "description" {
  type        = string
  default     = null
  description = "Default description for all Redis replication groups. Can be overridden per cluster in redis_clusters."
}

variable "family" {
  type        = string
  description = "Redis family"
}

variable "port" {
  type        = number
  description = "Port number"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for permitted ingress"
  default     = []
}

variable "allow_all_egress" {
  type        = bool
  default     = true
  description = <<-EOT
    If `true`, the created security group will allow egress on all ports and protocols to all IP address.
    If this is false and no egress rules are otherwise specified, then no egress will be allowed.
    EOT
}

variable "at_rest_encryption_enabled" {
  type        = bool
  description = "Enable encryption at rest"
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable TLS"
}

variable "transit_encryption_mode" {
  type        = string
  default     = null
  description = "Transit encryption mode. Valid values are 'preferred' and 'required'"
}

variable "auth_token_enabled" {
  type        = bool
  description = "Enable auth token"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Enable automatic failover"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. Only supported if the engine version is 6 or higher."
  default     = false
}

variable "cloudwatch_metric_alarms_enabled" {
  type        = bool
  description = "Boolean flag to enable/disable CloudWatch metrics alarms"
}

variable "redis_clusters" {
  type        = map(any)
  description = "Redis cluster configuration"
}

variable "allow_ingress_from_this_vpc" {
  type        = bool
  default     = true
  description = "If set to `true`, allow ingress from the VPC CIDR for this account"
}

variable "allow_ingress_from_vpc_stages" {
  type        = list(string)
  default     = []
  description = "List of stages to pull VPC ingress cidr and add to security group"
}

variable "eks_security_group_enabled" {
  type        = bool
  description = "Use the eks default security group"
  default     = false
}

variable "eks_component_names" {
  type        = set(string)
  description = "The names of the eks components"
  default     = []
}

variable "snapshot_retention_limit" {
  type        = number
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  default     = 0
}

variable "snapshot_window" {
  type        = string
  description = "The daily time range (in UTC) during which ElastiCache begins taking a daily snapshot. Format: hh:mm-hh:mm. Defaults to null (AWS chooses the window). Has no effect when snapshot_retention_limit is 0."
  default     = null

  validation {
    condition     = var.snapshot_window == null || can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]-([01][0-9]|2[0-3]):[0-5][0-9]$", var.snapshot_window))
    error_message = "snapshot_window must be in hh:mm-hh:mm format (UTC), e.g. \"05:00-06:00\"."
  }
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance window. Format: ddd:hh:mm-ddd:hh:mm (UTC). Defaults to null (AWS chooses the window)."
  default     = null

  validation {
    condition     = var.maintenance_window == null || can(regex("^(sun|mon|tue|wed|thu|fri|sat):([01][0-9]|2[0-3]):[0-5][0-9]-(sun|mon|tue|wed|thu|fri|sat):([01][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_window))
    error_message = "maintenance_window must be in ddd:hh:mm-ddd:hh:mm format (UTC), e.g. \"tue:05:00-tue:06:00\"."
  }
}

variable "elasticache_subnet_group_name" {
  type        = string
  description = "Subnet group name for the ElastiCache instance"
  default     = ""
}

variable "network_type" {
  type        = string
  default     = "ipv4"
  description = "The network type of the cluster. Valid values: ipv4, ipv6, dual_stack."
}

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "Notification topic arn"
}

variable "alarm_cpu_threshold_percent" {
  type        = number
  default     = 75
  description = "CPU threshold alarm level"
}

variable "alarm_memory_threshold_bytes" {
  type        = number
  default     = 10000000
  description = "Ram threshold alarm level"
}

variable "alarm_actions" {
  type        = list(string)
  description = "Alarm action list"
  default     = []
}

variable "ok_actions" {
  type        = list(string)
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Number (ARN)"
  default     = []
}

variable "data_tiering_enabled" {
  type        = bool
  default     = false
  description = "Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type."
}

variable "auth_token_update_strategy" {
  type        = string
  description = "Strategy to use when updating the auth_token. Valid values are `SET`, `ROTATE`, and `DELETE`. Defaults to `ROTATE`."
  default     = "ROTATE"

  validation {
    condition     = contains(["set", "rotate", "delete"], lower(var.auth_token_update_strategy))
    error_message = "Valid values for auth_token_update_strategy are `SET`, `ROTATE`, and `DELETE`."
  }
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. `at_rest_encryption_enabled` must be set to `true`"
  default     = null
}

variable "parameter_group_description" {
  type        = string
  default     = null
  description = "Managed by Terraform"
}

variable "log_delivery_configuration" {
  type        = list(map(any))
  default     = []
  description = "The log_delivery_configuration block allows the streaming of Redis SLOWLOG or Redis Engine Log to CloudWatch Logs or Kinesis Data Firehose. Max of 2 blocks."
}

variable "user_group_ids" {
  type        = list(string)
  default     = null
  description = "User Group ID to associate with the replication group"
}

variable "global_replication_group_id" {
  type        = string
  default     = null
  description = "The ID of the global replication group to which this replication group should belong. If this parameter is specified, the replication group is added to the specified global replication group as a secondary replication group; otherwise, the replication group is not part of any global replication group. If global_replication_group_id is set, the num_node_groups parameter cannot be set."
}

variable "vpc_component_name" {
  type        = string
  description = "The name of a VPC component"
  default     = "vpc"
}

variable "vpc_ingress_component_name" {
  type        = string
  description = "The name of a Ingress VPC component"
  default     = "vpc"
}

variable "dns_delegated_component_name" {
  type        = string
  description = "The name of the Delegated DNS component"
  default     = "dns-delegated"
}
