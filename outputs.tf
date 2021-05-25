output "master_username" {
  value       = join("", aws_docdb_cluster.default.*.master_username)
  description = "Username for the master DB user"
}

output "cluster_name" {
  value       = join("", aws_docdb_cluster.default.*.cluster_identifier)
  description = "Cluster Identifier"
}

output "arn" {
  value       = join("", aws_docdb_cluster.default.*.arn)
  description = "Amazon Resource Name (ARN) of the cluster"
}

output "endpoint" {
  value       = join("", aws_docdb_cluster.default.*.endpoint)
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = join("", aws_docdb_cluster.default.*.reader_endpoint)
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = module.dns_master.hostname
  description = "DB master hostname"
}

output "replicas_host" {
  value       = module.dns_replicas.hostname
  description = "DB replicas hostname"
}

output "security_group_id" {
  value       = module.security_group.id
  description = "DocumentDB Security Group ID"
}

output "security_group_arn" {
  value       = module.security_group.arn
  description = "DocumentDB Security Group ARN"
}

output "security_group_name" {
  value       = module.security_group.name
  description = "DocumentDB Security Group name"
}
