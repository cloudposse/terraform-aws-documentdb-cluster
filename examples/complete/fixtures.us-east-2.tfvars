enabled = true

region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "documentdb-cluster"

vpc_cidr_block = "172.16.0.0/16"

instance_class = "db.r4.large"

cluster_size = 1

db_port = 27017

master_username = "admin1"

master_password = "password1"

retention_period = 5

preferred_backup_window = "07:00-09:00"

cluster_family = "docdb3.6"

engine = "docdb"

storage_encrypted = true

skip_final_snapshot = true

apply_immediately = true
