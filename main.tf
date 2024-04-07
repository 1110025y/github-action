# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.43.0"
    }
  }
}

# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}


# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project_name" {
  type = map(any)
}

variable "availability_zones" {
  type = list(any)
}

variable "zones" {
  type = list(any)
}

variable "alarm_config" {
  type = map(string)
}