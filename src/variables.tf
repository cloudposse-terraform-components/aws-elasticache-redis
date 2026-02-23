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
