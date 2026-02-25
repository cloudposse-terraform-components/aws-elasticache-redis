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

    elasticache_subnet_group_name = optional(string, "")
    network_type                  = optional(string, "ipv4")
    notification_topic_arn        = optional(string, "")
    alarm_cpu_threshold_percent   = optional(number, 75)
    alarm_memory_threshold_bytes  = optional(number, 10000000)
    alarm_actions                 = optional(list(string), [])
    ok_actions                    = optional(list(string), [])
    data_tiering_enabled          = optional(bool, false)
    auth_token_update_strategy    = optional(string, "ROTATE")
    kms_key_id                    = optional(string, null)
    parameter_group_description   = optional(string, null)
    log_delivery_configuration    = optional(list(map(any)), [])
    user_group_ids                = optional(list(string), null)
    global_replication_group_id   = optional(string, null)
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

variable "snapshot_name" {
  type        = string
  description = "The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
  default     = null
}

variable "snapshot_arns" {
  type        = list(string)
  description = "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. Example: arn:aws:s3:::my_bucket/snapshot1.rdb"
  default     = []
}

variable "final_snapshot_identifier" {
  type        = string
  description = "The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster. If omitted, no final snapshot will be made."
  default     = null
}

variable "replication_group_id" {
  type        = string
  description = "Replication group ID with the following constraints: \nA name must contain from 1 to 20 alphanumeric characters or hyphens. \n The first character must be a letter. \n A name cannot end with a hyphen or contain two consecutive hyphens."
  default     = ""
}

variable "description" {
  type        = string
  description = "Description of elasticache replication group"
  default     = null
}
