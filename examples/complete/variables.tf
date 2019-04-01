variable "region" {
  type        = "string"
  description = "AWS Region"
  default     = "us-west-2"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = "eg"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = "testing"
}

variable "name" {
  type        = "string"
  description = "Name of the application"
  default     = "docdb"
}
