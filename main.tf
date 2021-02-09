resource "aws_security_group" "default" {
  count       = module.this.enabled ? 1 : 0
  name        = module.this.id
  description = "Security Group for DocumentDB cluster"
  vpc_id      = var.vpc_id
  tags        = module.this.tags
}

resource "aws_security_group_rule" "egress" {
  count             = module.this.enabled ? 1 : 0
  type              = "egress"
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = module.this.enabled ? length(var.allowed_security_groups) : 0
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
  count             = module.this.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_docdb_cluster" "default" {
  count                           = module.this.enabled ? 1 : 0
  cluster_identifier              = module.this.id
  master_username                 = var.master_username
  master_password                 = var.master_password
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  final_snapshot_identifier       = lower(module.this.id)
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  port                            = var.db_port
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = [join("", aws_security_group.default.*.id)]
  db_subnet_group_name            = join("", aws_docdb_subnet_group.default.*.name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.default.*.name)
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                            = module.this.tags
}

resource "aws_docdb_cluster_instance" "default" {
  count                      = module.this.enabled ? var.cluster_size : 0
  identifier                 = "${module.this.id}-${count.index + 1}"
  cluster_identifier         = join("", aws_docdb_cluster.default.*.id)
  apply_immediately          = var.apply_immediately
  instance_class             = var.instance_class
  engine                     = var.engine
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  tags                       = module.this.tags
}

resource "aws_docdb_subnet_group" "default" {
  count       = module.this.enabled ? 1 : 0
  name        = module.this.id
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags        = module.this.tags
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  count       = module.this.enabled ? 1 : 0
  name        = module.this.id
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

  tags = module.this.tags
}

locals {
  cluster_dns_name_default  = "master.${module.this.name}"
  cluster_dns_name          = var.cluster_dns_name != "" ? var.cluster_dns_name : local.cluster_dns_name_default
  replicas_dns_name_default = "replicas.${module.this.name}"
  replicas_dns_name         = var.reader_dns_name != "" ? var.reader_dns_name : local.replicas_dns_name_default
}

module "dns_master" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.0"

  enabled  = module.this.enabled && var.zone_id != "" ? true : false
  dns_name = local.cluster_dns_name
  zone_id  = var.zone_id
  records  = coalescelist(aws_docdb_cluster.default.*.endpoint, [""])

  context = module.this.context
}

module "dns_replicas" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.12.0"

  enabled  = module.this.enabled && var.zone_id != "" ? true : false
  dns_name = local.replicas_dns_name
  zone_id  = var.zone_id
  records  = coalescelist(aws_docdb_cluster.default.*.reader_endpoint, [""])

  context = module.this.context
}
