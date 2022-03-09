output "public_subnet_cidrs" {
  value       = module.subnets.public_subnet_cidrs
  description = "Public subnet CIDRs"
}

output "private_subnet_cidrs" {
  value       = module.subnets.private_subnet_cidrs
  description = "Private subnet CIDRs"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC ID"
}

output "master_username" {
  value       = module.documentdb_cluster.master_username
  description = "DocumentDB Username for the master DB user"
}

output "cluster_name" {
  value       = module.documentdb_cluster.cluster_name
  description = "DocumentDB Cluster Identifier"
}

output "instance_name" {
  value       = module.documentdb_cluster.instance_name
  description = "DocumentDB Cluster Instance Identifier"
}

output "arn" {
  value       = module.documentdb_cluster.arn
  description = "Amazon Resource Name (ARN) of the DocumentDB cluster"
}

output "endpoint" {
  value       = module.documentdb_cluster.endpoint
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = module.documentdb_cluster.reader_endpoint
  description = "Read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = module.documentdb_cluster.master_host
  description = "DocumentDB master hostname"
}

output "replicas_host" {
  value       = module.documentdb_cluster.replicas_host
  description = "DocumentDB replicas hostname"
}

output "security_group_id" {
  value       = module.documentdb_cluster.security_group_id
  description = "ID of the DocumentDB cluster Security Group"
}

output "security_group_arn" {
  value       = module.documentdb_cluster.security_group_arn
  description = "ARN of the DocumentDB cluster Security Group"
}

output "security_group_name" {
  value       = module.documentdb_cluster.security_group_name
  description = "Name of the DocumentDB cluster Security Group"
}
