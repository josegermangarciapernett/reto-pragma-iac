/*
* # Stack: ElastiCache Redis
*/

resource "aws_elasticache_subnet_group" "this" {
  name       = local.workspace.redis.subnet_group_name
  subnet_ids = local.workspace.redis.private_subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.workspace.redis.replication_group_id
  description          = "Redis for ${var.prefix}-${terraform.workspace}"

  engine               = "redis"
  node_type            = local.workspace.redis.node_type
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = local.workspace.redis.security_group_ids

  automatic_failover_enabled = local.workspace.redis.automatic_failover_enabled
  multi_az_enabled           = local.workspace.redis.multi_az_enabled
  num_cache_clusters         = local.workspace.redis.num_cache_clusters

  tags = local.workspace.tags
}
