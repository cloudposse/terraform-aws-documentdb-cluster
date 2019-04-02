output "master_username" {
  value       = "${join("", aws_docdb_cluster.default.*.master_username)}"
  description = "Username for the master DB user"
}

output "cluster_name" {
  value       = "${join("", aws_docdb_cluster.default.*.cluster_identifier)}"
  description = "Cluster Identifier"
}

output "arn" {
  value       = "${join("", aws_docdb_cluster.default.*.arn)}"
  description = "Amazon Resource Name (ARN) of cluster"
}

output "endpoint" {
  value       = "${join("", aws_docdb_cluster.default.*.endpoint)}"
  description = "The DNS address of the RDS instance"
}

output "reader_endpoint" {
  value       = "${join("", aws_docdb_cluster.default.*.reader_endpoint)}"
  description = "A read-only endpoint for the DocumentDB cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = "${module.dns_master.hostname}"
  description = "DB Master hostname"
}

output "replicas_host" {
  value       = "${module.dns_replicas.hostname}"
  description = "Replicas hostname"
}

output "security_group_id" {
  description = "ID of the DocumentDB cluster Security Group"
  value       = "${join("", aws_security_group.default.*.id)}"
}

output "security_group_arn" {
  description = "ARN of the DocumentDB cluster Security Group"
  value       = "${join("", aws_security_group.default.*.arn)}"
}

output "security_group_name" {
  description = "Name of the DocumentDB cluster Security Group"
  value       = "${join("", aws_security_group.default.*.name)}"
}
