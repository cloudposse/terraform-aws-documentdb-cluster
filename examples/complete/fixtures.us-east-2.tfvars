region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "documentdb-cluster"

vpc_cidr_block = "172.16.0.0/16"

instance_class = "db.t4g.medium"

cluster_size = 1

db_port = 27017

master_username = "admin1"

master_password = "password1"

retention_period = 5

preferred_backup_window = "07:00-09:00"

cluster_family = "docdb5.0"
engine_version = "5.0.0"

engine = "docdb"

storage_encrypted = true

storage_type = "standard"

skip_final_snapshot = true

apply_immediately = true

ssm_parameter_enabled = true
