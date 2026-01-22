variable "project_name" {
  description = "Project name"
  type        = string
  default     = "plcr"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dr"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "region_code" {
  description = "Region code"
  type        = string
  default     = "an1"
}
