# =============================================================================
# PLCR Cognito - Global Resources
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "plcr-s3-an2-tfstate"
    key            = "v3/cognito/global/terraform.tfstate"
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
  alias  = "seoul"
  region = "ap-northeast-2"
  
  default_tags {
    tags = {
      Project     = "plcr"
      Environment = "prod"
      ManagedBy   = "terraform"
      Module      = "cognito"
    }
  }
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
  
  default_tags {
    tags = {
      Project     = "plcr"
      Environment = "dr"
      ManagedBy   = "terraform"
      Module      = "cognito"
    }
  }
}
