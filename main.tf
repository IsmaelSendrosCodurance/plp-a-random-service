terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "isendros-plp-s3"
    key    = "plp-tf"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"
}