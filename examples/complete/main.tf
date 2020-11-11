/*
Useful references:

https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs
https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
https://www.terraform.io/docs/providers/aws/r/docdb_cluster.html
https://www.terraform.io/docs/providers/aws/r/docdb_cluster_instance.html
https://www.terraform.io/docs/providers/aws/r/docdb_cluster_parameter_group.html
https://www.terraform.io/docs/providers/aws/r/docdb_subnet_group.html
https://docs.aws.amazon.com/documentdb/latest/developerguide/troubleshooting.html
*/

provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.18.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.31.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  delimiter            = var.delimiter
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
  tags                 = var.tags
}

module "documentdb_cluster" {
  source                          = "../../"
  enabled                         = var.enabled
  namespace                       = var.namespace
  stage                           = var.stage
  name                            = var.name
  delimiter                       = var.delimiter
  attributes                      = var.attributes
  tags                            = var.tags
  cluster_size                    = var.cluster_size
  master_username                 = var.master_username
  master_password                 = var.master_password
  instance_class                  = var.instance_class
  db_port                         = var.db_port
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnets.private_subnet_ids
  zone_id                         = var.zone_id
  apply_immediately               = var.apply_immediately
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  allowed_security_groups         = var.allowed_security_groups
  allowed_cidr_blocks             = var.allowed_cidr_blocks
  snapshot_identifier             = var.snapshot_identifier
  retention_period                = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  cluster_parameters              = var.cluster_parameters
  cluster_family                  = var.cluster_family
  engine                          = var.engine
  engine_version                  = var.engine_version
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  skip_final_snapshot             = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  cluster_dns_name                = var.cluster_dns_name
  reader_dns_name                 = var.reader_dns_name
}
