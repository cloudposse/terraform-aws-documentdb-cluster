## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0, < 0.14.0 |
| aws | ~> 2.0 |
| local | ~> 1.3 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_cidr\_blocks | List of CIDR blocks to be allowed to connect to the DocumentDB cluster | `list(string)` | `[]` | no |
| allowed\_security\_groups | List of existing Security Groups to be allowed to connect to the DocumentDB cluster | `list(string)` | `[]` | no |
| apply\_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| attributes | Additional attributes (\_e.g.\_ "1") | `list(string)` | `[]` | no |
| cluster\_dns\_name | Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `master.var.name` | `string` | `""` | no |
| cluster\_family | The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html | `string` | `"docdb3.6"` | no |
| cluster\_parameters | List of DB parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| cluster\_size | Number of DB instances to create in the cluster | `number` | `3` | no |
| db\_port | DocumentDB port | `number` | `27017` | no |
| delimiter | Delimiter between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch. The following log types are supported: `audit`, `error`, `general`, `slowquery` | `list(string)` | `[]` | no |
| engine | The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb` | `string` | `"docdb"` | no |
| engine\_version | The version number of the database engine to use | `string` | `""` | no |
| instance\_class | The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs | `string` | `"db.r4.large"` | no |
| kms\_key\_id | The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true` | `string` | `""` | no |
| master\_password | (Required unless a snapshot\_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints | `string` | `""` | no |
| master\_username | (Required unless a snapshot\_identifier is provided) Username for the master DB user | `string` | `"admin1"` | no |
| name | Name of the application | `string` | n/a | yes |
| namespace | Namespace (e.g. `eg` or `cp`) | `string` | `""` | no |
| preferred\_backup\_window | Daily time range during which the backups happen | `string` | `"07:00-09:00"` | no |
| reader\_dns\_name | Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `replicas.var.name` | `string` | `""` | no |
| retention\_period | Number of days to retain backups for | `number` | `5` | no |
| skip\_final\_snapshot | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `true` | no |
| snapshot\_identifier | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | `string` | `""` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | `""` | no |
| storage\_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| subnet\_ids | List of VPC subnet IDs to place DocumentDB instances in | `list(string)` | n/a | yes |
| tags | Additional tags (\_e.g.\_ { BusinessUnit : ABC }) | `map(string)` | `{}` | no |
| vpc\_id | VPC ID to create the cluster in (e.g. `vpc-a22222ee`) | `string` | n/a | yes |
| zone\_id | Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the DocumentDB master and replicas | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Amazon Resource Name (ARN) of the cluster |
| cluster\_name | Cluster Identifier |
| endpoint | Endpoint of the DocumentDB cluster |
| master\_host | DB master hostname |
| master\_username | Username for the master DB user |
| reader\_endpoint | A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas |
| replicas\_host | DB replicas hostname |
| security\_group\_arn | ARN of the DocumentDB cluster Security Group |
| security\_group\_id | ID of the DocumentDB cluster Security Group |
| security\_group\_name | Name of the DocumentDB cluster Security Group |

