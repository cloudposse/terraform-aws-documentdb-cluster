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
  source  = "cloudposse/vpc/aws"
  version = "2.1.1"

  ipv4_primary_cidr_block = var.vpc_cidr_block

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.2"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "documentdb_cluster" {
  source                          = "../../"
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
  storage_type                    = var.storage_type
  kms_key_id                      = var.kms_key_id
  skip_final_snapshot             = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  cluster_dns_name                = var.cluster_dns_name
  reader_dns_name                 = var.reader_dns_name
  ssm_parameter_enabled           = var.ssm_parameter_enabled

  context = module.this.context
}
