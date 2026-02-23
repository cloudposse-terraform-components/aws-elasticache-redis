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

variable "num_shards" {
  type        = number
  default     = 0
  description = "Default number of shards (node groups) for Redis clusters. Value > 0 enables cluster mode. It can be overridden per cluster in redis_clusters."

  validation {
    condition     = var.num_shards >= 0 && var.num_shards <= 500
    error_message = "num_shards must be between 0 and 500; use 0 to disable cluster mode."
  }
}

variable "replicas_per_shard" {
  type        = number
  default     = 0
  description = "Default number of replica nodes per shard. Valid values are 0 to 5. It can be overridden per cluster in redis_clusters."

  validation {
    condition     = var.replicas_per_shard >= 0 && var.replicas_per_shard <= 5
    error_message = "replicas_per_shard must be between 0 and 5."
  }
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
