output "name" {
  value       = "${module.documentdb_cluster.name}"
  description = "Database name"
}

output "user" {
  value       = "${module.documentdb_cluster.user}"
  description = "Username for the master DB user"
}

output "cluster_name" {
  value       = "${module.documentdb_cluster.cluster_name}"
  description = "Cluster Identifier"
}

output "arn" {
  value       = "${module.documentdb_cluster.arn}"
  description = "Amazon Resource Name (ARN) of cluster"
}

output "endpoint" {
  value       = "${module.documentdb_cluster.endpoint}"
  description = "The DNS address of the RDS instance"
}

output "reader_endpoint" {
  value       = "${module.documentdb_cluster.reader_endpoint}"
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = "${module.documentdb_cluster.master_host}"
  description = "DB Master hostname"
}

output "replicas_host" {
  value       = "${module.documentdb_cluster.replicas_host}"
  description = "Replicas hostname"
}
