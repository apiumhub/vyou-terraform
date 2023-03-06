provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_version = "~> 1.1.5"

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">=1.13.1"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "2.4.1"
    }
    http-hashicorp = {
      source = "hashicorp/http"
      version = "~> 2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.4"
    }
  }
}

provider "http-hashicorp" {
}
