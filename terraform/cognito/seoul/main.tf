# =============================================================================
# PLCR Cognito - Seoul Region
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  # Cognito 전용 tfstate (기존 인프라와 분리)
  backend "s3" {
    bucket         = "plcr-s3-an2-tfstate"
    key            = "v3/cognito/seoul/terraform.tfstate"
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
