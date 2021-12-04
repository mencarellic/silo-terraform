terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.68.0"
    }
  }
}

provider "aws" {
  alias  = "west-2"
  region = "us-west-2"
}
