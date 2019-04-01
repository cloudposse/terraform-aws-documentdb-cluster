## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin_password | (Required unless a snapshot_identifier is provided) Password for the master DB user | string | `` | no |
| admin_user | (Required unless a snapshot_identifier is provided) Username for the master DB user | string | `admin` | no |
| allowed_cidr_blocks | List of CIDR blocks to be allowed to connect to the DocumentDB cluster | list | `<list>` | no |
| allowed_security_groups | List of existing Security Groups to be allowed to connect to the DocumentDB cluster | list | `<list>` | no |
| apply_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | string | `true` | no |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| cluster_family | The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html | string | `docdb3.6` | no |
| cluster_parameters | List of DB parameters to apply | list | `<list>` | no |
| cluster_size | Number of DB instances to create in the cluster | string | `2` | no |
| db_port | DocumentDB port | string | `27017` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage` and `attributes` | string | `-` | no |
| enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| enabled_cloudwatch_logs_exports | List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery. | list | `<list>` | no |
| engine | The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb` | string | `docdb` | no |
| engine_version | The version number of the database engine to use | string | `` | no |
| instance_class | The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs | string | `db.r4.large` | no |
| kms_key_id | The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true` | string | `` | no |
| name | Name of the application | string | - | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | string | - | yes |
| preferred_backup_window | Daily time range during which the backups happen | string | `07:00-09:00` | no |
| retention_period | Number of days to retain backups for | string | `5` | no |
| skip_final_snapshot | Determines whether a final DB snapshot is created before the DB cluster is deleted | string | `true` | no |
| snapshot_identifier | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | string | `` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| storage_encrypted | Specifies whether the DB cluster is encrypted. The default is `false` for `provisioned` `engine_mode` and `true` for `serverless` `engine_mode` | string | `true` | no |
| subnet_ids | List of VPC subnet IDs | list | - | yes |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | map | `<map>` | no |
| vpc_id | VPC ID to create the cluster in (e.g. `vpc-a22222ee`) | string | - | yes |
| zone_id | Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the DB master and replicas | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Amazon Resource Name (ARN) of cluster |
| cluster_name | Cluster Identifier |
| endpoint | The DNS address of the RDS instance |
| master_host | DB Master hostname |
| name | Database name |
| reader_endpoint | A read-only endpoint for the DocumentDB cluster, automatically load-balanced across replicas |
| replicas_host | Replicas hostname |
| security_group_arn | ARN of the DocumentDB cluster Security Group |
| security_group_id | ID of the DocumentDB cluster Security Group |
| security_group_name | Name of the DocumentDB cluster Security Group |
| user | Username for the master DB user |

