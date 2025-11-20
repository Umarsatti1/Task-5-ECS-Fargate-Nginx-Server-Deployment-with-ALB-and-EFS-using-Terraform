terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.21.0"
    }
  }

  backend "s3" {
    bucket         = "umarsatti-terraform-s3-bucket-state-file"  
    key            = "Task-5/terraform.tfstate"
    region         = "us-west-2"  
    encrypt        = true
    use_lockfile   = true
  }
}

provider "aws" {
    region = "us-west-2"
}