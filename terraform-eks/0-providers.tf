provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.4.2"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.19.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}
