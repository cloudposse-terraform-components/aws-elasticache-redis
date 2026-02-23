# API Response Redis Cluster Vars

variable "cluster_name" {
  type        = string
  description = "Elasticache Cluster name"
}

variable "create_parameter_group" {
  type        = bool
  default     = true
  description = "Whether new parameter group should be created. Set to false if you want to use existing parameter group"
}

variable "engine" {
  type        = string
  default     = "redis"
  description = "Name of the cache engine to use: either `redis` or `valkey`"
}

variable "engine_version" {
  type        = string
  description = "Version of the cache engine to use"
  default     = "6.0.5"
}

variable "dns_subdomain" {
  type        = string
  description = "Name of DNS subdomain to prepend to Route53 zone DNS name"
}

variable "num_replicas" {
  type        = number
  description = "Number of replicas in replica set"
}

variable "instance_type" {
  type        = string
  description = "Elastic cache instance type"
}

variable "num_shards" {
  type        = number
  description = "Number of node groups (shards) for this Redis cluster. Value > 0 sets cluster mode to true.  Changing this number will trigger an online resizing operation before other settings modifications"
  default     = 0
}

variable "replicas_per_shard" {
  type        = number
  description = "Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will force a new resource"
  default     = 0
}

variable "cluster_attributes" {
  type = object({
    availability_zones              = list(string)
    vpc_id                          = string
    additional_security_group_rules = list(any)
    allowed_security_groups         = list(string)
    allow_all_egress                = bool
    subnets                         = list(string)
    family                          = string
    port                            = number
    zone_id                         = string
    multi_az_enabled                = bool
    at_rest_encryption_enabled      = bool
    transit_encryption_enabled      = bool
    transit_encryption_mode         = string
    apply_immediately               = bool
    automatic_failover_enabled      = bool
    auto_minor_version_upgrade      = bool
    auth_token_enabled              = bool
    snapshot_retention_limit        = number
    snapshot_window                 = optional(string, null)
    maintenance_window              = optional(string, null)
  })
  description = "Cluster attributes"
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Parameters to configure cluster parameter group"
  default     = []
}

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Override the default parameter group name"
}

variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "slow_logs_enabled" {
  type        = bool
  default     = false
  description = "Enable slow logs delivery to CloudWatch Logs"
}

variable "engine_logs_enabled" {
  type        = bool
  default     = false
  description = "Enable engine logs delivery to CloudWatch Logs"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch Log Group retention in days for Redis logs"

  validation {
    condition = contains(
      [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
      var.log_retention_days
    )
    error_message = "log_retention_days must be one of the valid AWS CloudWatch retention periods: 0 (never expire), 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}
