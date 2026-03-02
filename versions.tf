terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 1.0"
    }
  }
}
