output "master_username" {
  value       = "${module.documentdb_cluster.master_username}"
  description = "DocumentDB Username for the master DB user"
}

output "cluster_name" {
  value       = "${module.documentdb_cluster.cluster_name}"
  description = "DocumentDB Cluster Identifier"
}

output "arn" {
  value       = "${module.documentdb_cluster.arn}"
  description = "Amazon Resource Name (ARN) of the DocumentDB cluster"
}

output "endpoint" {
  value       = "${module.documentdb_cluster.endpoint}"
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = "${module.documentdb_cluster.reader_endpoint}"
  description = "Read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "master_host" {
  value       = "${module.documentdb_cluster.master_host}"
  description = "DocumentDB master hostname"
}

output "replicas_host" {
  value       = "${module.documentdb_cluster.replicas_host}"
  description = "DocumentDB replicas hostname"
}
