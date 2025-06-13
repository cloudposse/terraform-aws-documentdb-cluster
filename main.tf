locals {
  enabled         = module.this.enabled
  create_password = local.enabled && var.master_password == null

  master_password = local.create_password ? one(random_password.password[*].result) : var.master_password
}

resource "aws_security_group" "default" {
  count       = local.enabled ? 1 : 0
  name        = module.this.id
  description = "Security Group for DocumentDB cluster"
  vpc_id      = var.vpc_id
  tags        = module.this.tags
}

resource "aws_security_group_rule" "egress" {
  count             = local.enabled ? 1 : 0
  type              = "egress"
  description       = "Allow outbound traffic from CIDR blocks"
  from_port         = var.egress_from_port
  to_port           = var.egress_to_port
  protocol          = var.egress_protocol
  cidr_blocks       = var.allowed_egress_cidr_blocks
  security_group_id = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "allow_ingress_from_self" {
  count             = local.enabled && var.allow_ingress_from_self ? 1 : 0
  type              = "ingress"
  description       = "Allow traffic within the security group"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  security_group_id = join("", aws_security_group.default[*].id)
  self              = true
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = local.enabled ? length(var.allowed_security_groups) : 0
  type                     = "ingress"
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  type              = "ingress"
  count             = local.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default[*].id)
}

resource "random_password" "password" {
  count   = local.create_password ? 1 : 0
  length  = 16
  special = false
}

resource "aws_docdb_cluster" "default" {
  count                           = local.enabled ? 1 : 0
  cluster_identifier              = module.this.id
  master_username                 = var.master_username
  master_password                 = local.master_password
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  final_snapshot_identifier       = lower(module.this.id)
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  storage_type                    = var.storage_type
  kms_key_id                      = var.kms_key_id
  port                            = var.db_port
  snapshot_identifier             = var.snapshot_identifier
  manage_master_user_password     = var.manage_master_user_password
  vpc_security_group_ids          = concat([join("", aws_security_group.default[*].id)], var.external_security_group_id_list)
  db_subnet_group_name            = join("", aws_docdb_subnet_group.default[*].name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.default[*].name)
  engine                          = var.engine
  engine_version                  = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  tags                            = module.this.tags
}

resource "aws_docdb_cluster_instance" "default" {
  count                        = local.enabled ? var.cluster_size : 0
  identifier                   = "${module.this.id}-${count.index + 1}"
  cluster_identifier           = join("", aws_docdb_cluster.default[*].id)
  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window
  instance_class               = var.instance_class
  engine                       = var.engine
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  enable_performance_insights  = var.enable_performance_insights
  ca_cert_identifier           = var.ca_cert_identifier
  tags                         = module.this.tags
}

resource "aws_docdb_subnet_group" "default" {
  count       = local.enabled ? 1 : 0
  name        = module.this.id
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags        = module.this.tags
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  count       = local.enabled ? 1 : 0
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
  version = "0.13.0"

  enabled  = local.enabled && var.zone_id != "" ? true : false
  dns_name = local.cluster_dns_name
  zone_id  = var.zone_id
  records  = coalescelist(aws_docdb_cluster.default[*].endpoint, [""])

  context = module.this.context
}

module "dns_replicas" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.13.0"

  enabled  = local.enabled && var.zone_id != "" ? true : false
  dns_name = local.replicas_dns_name
  zone_id  = var.zone_id
  records  = coalescelist(aws_docdb_cluster.default[*].reader_endpoint, [""])

  context = module.this.context
}

module "ssm_write_db_password" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  enabled = local.enabled && var.ssm_parameter_enabled == true && var.manage_master_user_password != null ? true : false
  parameter_write = [
    {
      name        = format("%s%s", var.ssm_parameter_path_prefix, module.this.id)
      value       = local.master_password
      type        = "SecureString"
      description = "Master password for ${module.this.id} DocumentDB cluster"
    }
  ]

  context = module.this.context
}
