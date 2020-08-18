locals {
  db_subnet_group_name = var.db_subnet_group_name == "" ? module.label.id : var.db_subnet_group_name
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_security_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = module.label.id
  description = "Security Group for DocumentDB cluster"
  vpc_id      = var.vpc_id
  tags        = module.label.tags
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  type              = "egress"
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled ? length(var.allowed_security_groups) : 0
  type                     = "ingress"
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  type              = "ingress"
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_docdb_cluster" "default" {
  count                           = var.enabled ? 1 : 0
  cluster_identifier              = module.label.id
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  final_snapshot_identifier       = lower(module.label.id)
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = [join("", aws_security_group.default.*.id)]
  db_subnet_group_name            = join("", aws_docdb_subnet_group.default.*.name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.default.*.name)
  deletion_protection             = var.deletion_protection
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                            = module.label.tags

  lifecycle { # We do not want to change password, nor store the current in code nor state so ignoring changes from here
    ignore_changes = [
      master_password,
    ]
  }

}

resource "aws_docdb_cluster_instance" "default" {
  count              = var.enabled ? var.cluster_size : 0
  identifier         = "${module.label.id}-${count.index + 1}"
  cluster_identifier = join("", aws_docdb_cluster.default.*.id)
  apply_immediately  = var.apply_immediately
  instance_class     = var.instance_class
  tags               = module.label.tags
  engine             = var.engine
}

resource "aws_docdb_subnet_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = local.db_subnet_group_name
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags        = merge(module.label.tags, {"Name" = local.db_subnet_group_name})
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = module.label.id
  description = "DB cluster parameter group"
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = module.label.tags
}

locals {
  cluster_dns_name_default  = "master.${var.name}"
  cluster_dns_name          = var.cluster_dns_name != "" ? var.cluster_dns_name : local.cluster_dns_name_default
  replicas_dns_name_default = "replicas.${var.name}"
  replicas_dns_name         = var.reader_dns_name != "" ? var.reader_dns_name : local.replicas_dns_name_default
}

module "dns_master" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.5.0"
  enabled = var.enabled && var.zone_id != "" ? true : false
  name    = local.cluster_dns_name
  zone_id = var.zone_id
  records = coalescelist(aws_docdb_cluster.default.*.endpoint, [""])
}

module "dns_replicas" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.5.0"
  enabled = var.enabled && var.zone_id != "" ? true : false
  name    = local.replicas_dns_name
  zone_id = var.zone_id
  records = coalescelist(aws_docdb_cluster.default.*.reader_endpoint, [""])
}
