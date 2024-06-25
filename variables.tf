variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the DocumentDB master and replicas"
}

variable "egress_from_port" {
  type        = number
  default     = 0
  description = "[from_port]DocumentDB initial port range for egress (e.g. `0`)"
}

variable "egress_to_port" {
  type        = number
  default     = 0
  description = "[to_port]DocumentDB initial port range for egress (e.g. `65535`)"
}

variable "egress_protocol" {
  type        = string
  default     = "-1"
  description = "DocumentDB protocol for egress (e.g. `-1`, `tcp`)"
}

variable "allowed_egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to be allowed to send traffic outside of the DocumentDB cluster"
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of existing Security Groups to be allowed to connect to the DocumentDB cluster"
}

variable "allow_ingress_from_self" {
  type        = bool
  default     = false
  description = "Adds the Document DB security group itself as a source for ingress rules. Useful when this security group will be shared with applications."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the DocumentDB cluster"
}

variable "external_security_group_id_list" {
  type        = list(string)
  default     = []
  description = "List of external security group IDs to attach to the Document DB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs to place DocumentDB instances in"
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/limits.html#suported-instance-types
variable "instance_class" {
  type        = string
  default     = "db.r4.large"
  description = "The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs"
}

variable "cluster_size" {
  type        = number
  default     = 3
  description = "Number of DB instances to create in the cluster"
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
}

variable "db_port" {
  type        = number
  default     = 27017
  description = "DocumentDB port"
}

variable "master_username" {
  type        = string
  default     = "admin1"
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "master_password" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints"
}

variable "retention_period" {
  type        = number
  default     = 5
  description = "Number of days to retain backups for"
}

variable "preferred_backup_window" {
  type        = string
  default     = "07:00-09:00"
  description = "Daily time range during which the backups happen"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "Mon:22:00-Mon:23:00"
  description = "The window to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`."
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB parameters to apply"
}

variable "cluster_family" {
  type        = string
  default     = "docdb3.6"
  description = "The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html"
}

variable "engine" {
  type        = string
  default     = "docdb"
  description = "The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`"
}

variable "engine_version" {
  type        = string
  default     = "3.6.0"
  description = "The version number of the database engine to use"
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted"
  default     = true
}

variable "storage_type" {
  type        = string
  description = "The storage type to associate with the DB cluster. Valid values: standard, iopt1"
  default     = "standard"

  validation {
    condition     = contains(["standard", "iopt1"], var.storage_type)
    error_message = "Error: storage_type value must be one of two options - 'standard' or 'iopt1'."
  }
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  default     = ""
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "A value that indicates whether the DB cluster has deletion protection enabled"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = true
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Specifies whether any minor engine upgrades will be applied automatically to the DB instance during the maintenance window or not"
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: `audit`, `profiler`"
  default     = []
}

variable "cluster_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `master.var.name`"
  default     = ""
}

variable "reader_dns_name" {
  type        = string
  description = "Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `replicas.var.name`"
  default     = ""
}

variable "enable_performance_insights" {
  type        = bool
  description = "Specifies whether to enable Performance Insights for the DB Instance."
  default     = false
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance"
  default     = null
}

variable "ssm_parameter_enabled" {
  type        = bool
  default     = false
  description = "Whether an SSM parameter store value is created to store the database password."
}

variable "ssm_parameter_path_prefix" {
  type        = string
  default     = "/docdb/master-password/"
  description = "The path prefix for the created SSM parameter e.g. '/docdb/master-password/dev'. `ssm_parameter_enabled` must be set to `true` for this to take affect."
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Specifies whether major version upgrades are allowed. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster#allow_major_version_upgrade"
  default     = false
}
