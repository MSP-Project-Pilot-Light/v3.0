# =============================================================================
# PLCR Cognito - Tokyo Region
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "plcr-s3-an2-tfstate"
    key            = "v3/cognito/tokyo/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "plcr-tbl-an2-tfstate-lock"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "cognito"
    }
  }
}
