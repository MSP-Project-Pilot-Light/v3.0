# Pre-Signup Lambda
resource "aws_lambda_function" "pre_signup_tokyo" {
  function_name = "plcr-lambda-an1-cognito-presignup"
  role          = aws_iam_role.cognito_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  
  filename         = "${path.module}/../../../lambda/cognito-pre-signup-tokyo.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../lambda/cognito-pre-signup-tokyo.zip")
  
  environment {
    variables = {
      USER_TABLE_NAME = "plcr-gtbl-users"
      AWS_REGION_CODE = "an1"
    }
  }
}

# User Migration Lambda
resource "aws_lambda_function" "user_migration_tokyo" {
  function_name = "plcr-lambda-an1-cognito-migration"
  role          = aws_iam_role.cognito_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  
  filename         = "${path.module}/../../../lambda/cognito-user-migration-tokyo.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../lambda/cognito-user-migration-tokyo.zip")
  
  environment {
    variables = {
      USER_TABLE_NAME = "plcr-gtbl-users"
    }
  }
}

# Pre-Authentication Lambda
resource "aws_lambda_function" "pre_auth_tokyo" {
  function_name = "plcr-lambda-an1-cognito-preauth"
  role          = aws_iam_role.cognito_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  
  filename         = "${path.module}/../../../lambda/cognito-pre-auth-tokyo.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../lambda/cognito-pre-auth-tokyo.zip")
  
  environment {
    variables = {
      USER_TABLE_NAME = "plcr-gtbl-users"
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "cognito_lambda" {
  name = "plcr-role-an1-cognito-lambda"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for DynamoDB Access
resource "aws_iam_role_policy" "cognito_lambda_dynamodb" {
  name = "plcr-pol-an1-lambda-gtbl"
  role = aws_iam_role.cognito_lambda.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query"
      ]
      Resource = [
        "arn:aws:dynamodb:ap-northeast-1:*:table/plcr-gtbl-users",
        "arn:aws:dynamodb:ap-northeast-1:*:table/plcr-gtbl-users/index/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_lambda_logs" {
  role       = aws_iam_role.cognito_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
