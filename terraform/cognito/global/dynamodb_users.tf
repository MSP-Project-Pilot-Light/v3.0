# DynamoDB Users Global Table
resource "aws_dynamodb_table" "users" {
  provider = aws.seoul
  
  name         = "plcr-gtbl-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"
  
  attribute {
    name = "email"
    type = "S"
  }
  
  attribute {
    name = "userId"
    type = "S"
  }
  
  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }
  
  # Seoul ↔ Tokyo 양방향 복제
  replica {
    region_name = "ap-northeast-1"
  }
  
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  point_in_time_recovery {
    enabled = true
  }
  
  # AWS Managed KMS 사용
  server_side_encryption {
    enabled = true
  }
}

# Output: DynamoDB ARN
output "dynamodb_users_table_arn" {
  description = "DynamoDB Users table ARN"
  value       = aws_dynamodb_table.users.arn
}

output "dynamodb_users_table_name" {
  description = "DynamoDB Users table name"
  value       = aws_dynamodb_table.users.name
}
