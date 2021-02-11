<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2.0 |
| local | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allowed\_cidr\_blocks | List of CIDR blocks to be allowed to connect to the DocumentDB cluster | `list(string)` | `[]` | no |
| allowed\_security\_groups | List of existing Security Groups to be allowed to connect to the DocumentDB cluster | `list(string)` | `[]` | no |
| apply\_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| auto\_minor\_version\_upgrade | Specifies whether any minor engine upgrades will be applied automatically to the DB instance during the maintenance window or not | `bool` | `true` | no |
| cluster\_dns\_name | Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `master.var.name` | `string` | `""` | no |
| cluster\_family | The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html | `string` | `"docdb3.6"` | no |
| cluster\_parameters | List of DB parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| cluster\_size | Number of DB instances to create in the cluster | `number` | `3` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| db\_port | DocumentDB port | `number` | `27017` | no |
| deletion\_protection | A value that indicates whether the DB cluster has deletion protection enabled | `bool` | `false` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch. The following log types are supported: `audit`, `error`, `general`, `slowquery` | `list(string)` | `[]` | no |
| engine | The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb` | `string` | `"docdb"` | no |
| engine\_version | The version number of the database engine to use | `string` | `""` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| instance\_class | The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs | `string` | `"db.r4.large"` | no |
| kms\_key\_id | The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true` | `string` | `""` | no |
| label\_key\_case | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| label\_value\_case | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| master\_password | (Required unless a snapshot\_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints | `string` | `""` | no |
| master\_username | (Required unless a snapshot\_identifier is provided) Username for the master DB user | `string` | `"admin1"` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| preferred\_backup\_window | Daily time range during which the backups happen | `string` | `"07:00-09:00"` | no |
| preferred\_maintenance\_window | The window to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`. | `string` | `"Mon:22:00-Mon:23:00"` | no |
| reader\_dns\_name | Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `replicas.var.name` | `string` | `""` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| retention\_period | Number of days to retain backups for | `number` | `5` | no |
| skip\_final\_snapshot | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `true` | no |
| snapshot\_identifier | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | `string` | `""` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| storage\_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| subnet\_ids | List of VPC subnet IDs to place DocumentDB instances in | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
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

<!-- markdownlint-restore -->
