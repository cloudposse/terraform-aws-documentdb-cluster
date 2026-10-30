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

variable "restore_to_point_in_time" {
  type = object({
    source_cluster_identifier  = string
    restore_type               = optional(string)
    restore_to_time            = optional(string)
    use_latest_restorable_time = optional(bool)
  })
  default     = null
  description = <<-EOT
    Restore the cluster to a point in time from an existing source cluster instead of creating an empty cluster. Cannot be used together with `snapshot_identifier`.
    `source_cluster_identifier`: Identifier of the existing source DocumentDB cluster.
    `restore_type`: Type of restore to perform, either `full-copy` or `copy-on-write`. Defaults to `full-copy` (AWS default).
    `restore_to_time`: UTC date and time to restore to, in RFC3339 format (for example `2026-07-03T12:30:00Z`). Cannot be set together with `use_latest_restorable_time = true`.
    `use_latest_restorable_time`: Set to `true` to restore to the latest restorable time.
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster#restore-to-point-in-time
    EOT

  validation {
    condition     = var.restore_to_point_in_time == null || try(contains(["full-copy", "copy-on-write"], coalesce(var.restore_to_point_in_time.restore_type, "full-copy")), false)
    error_message = "restore_to_point_in_time.restore_type must be either \"full-copy\" or \"copy-on-write\"."
  }

  validation {
    condition     = var.restore_to_point_in_time == null || !(try(var.restore_to_point_in_time.restore_to_time, null) != null && try(var.restore_to_point_in_time.use_latest_restorable_time, false) == true)
    error_message = "restore_to_point_in_time.restore_to_time cannot be set when use_latest_restorable_time is true."
  }

  validation {
    condition     = var.restore_to_point_in_time == null || try(var.restore_to_point_in_time.restore_to_time, null) != null || try(var.restore_to_point_in_time.use_latest_restorable_time, false) == true
    error_message = "restore_to_point_in_time requires either restore_to_time or use_latest_restorable_time = true."
  }
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
  default     = null
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints"
}

variable "manage_master_user_password" {
  type        = bool
  description = "Whether to manage the master user password using AWS Secrets Manager."
  default     = null
  validation {
    condition     = var.manage_master_user_password == null || var.manage_master_user_password == true
    error_message = "Error: `manage_master_user_password` must be set to `true` or `null`"
  }
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

variable "copy_tags_to_snapshot" {
  type        = bool
  default     = false
  description = "Copy all DB instance tags to snapshots."
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

variable "serverless_v2_scaling_configuration" {
  type = object({
    min_capacity = optional(number, 0.5)
    max_capacity = optional(number, 256)
  })
  default     = null
  description = "Configuration for serverless v2 scaling. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster#serverless_v2_scaling_configuration"
}
