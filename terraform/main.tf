terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "wiz-terraform-state-anamilovanovic"
    key    = "wiz-exercise/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}