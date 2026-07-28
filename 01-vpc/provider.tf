terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }

  backend "s3" {
    bucket         = "shashikanth-s3-bucket"
    key            = "expense-dev-vpc"
    region         = "us-east-1"
    dynamodb_table = "shashikanth-s3-locking"
  }
}

# provide the authentication here

provider "aws" {
  region = "us-east-1"
  # Configuration options
}