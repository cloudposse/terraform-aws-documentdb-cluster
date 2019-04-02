# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs
# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
# https://www.terraform.io/docs/providers/aws/r/docdb_cluster.html
# https://www.terraform.io/docs/providers/aws/r/docdb_cluster_instance.html
# https://www.terraform.io/docs/providers/aws/r/docdb_cluster_parameter_group.html
# https://www.terraform.io/docs/providers/aws/r/docdb_subnet_group.html

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.0"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  cidr_block = "172.16.0.0/16"
}

data "aws_availability_zones" "available" {}

locals {
  availability_zones = "${slice(data.aws_availability_zones.available.names, 0, 2)}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.6.0"
  availability_zones  = "${local.availability_zones}"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "documentdb_cluster" {
  source            = "../../"
  namespace         = "${var.namespace}"
  stage             = "${var.stage}"
  name              = "${var.name}"
  cluster_size      = "2"
  master_username   = "admin1"
  master_password   = "Test123456789"
  instance_class    = "db.r4.large"
  db_port           = 27017
  vpc_id            = "${module.vpc.vpc_id}"
  subnet_ids        = ["${module.subnets.private_subnet_ids}"]
  apply_immediately = "true"
}
