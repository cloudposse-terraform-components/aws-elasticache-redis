terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.73.0, < 7.0.0"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1.7.1, != 1.4.0, < 1.32.0"
    }
  }
}
