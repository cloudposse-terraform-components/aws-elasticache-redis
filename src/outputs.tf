output "redis_clusters" {
  description = "Redis cluster objects"
  value       = local.enabled ? local.clusters : {}
}

output "security_group_id" {
  description = "The security group ID of the ElastiCache Redis cluster"
  value       = local.enabled ? try(module.redis_clusters[keys(var.redis_clusters)[0]].security_group_id, null) : null
}
