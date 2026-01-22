# Cognito User Pool (Seoul)
resource "aws_cognito_user_pool" "seoul" {
  name = "plcr-pool-an2-auth"
  
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  
  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }
  
  mfa_configuration = "OPTIONAL"
  
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  
  lambda_config {
    pre_sign_up         = aws_lambda_function.pre_signup_seoul.arn
    user_migration      = aws_lambda_function.user_migration_seoul.arn
    pre_authentication  = aws_lambda_function.pre_auth_seoul.arn
  }
}

resource "aws_cognito_user_pool_client" "seoul_web" {
  name         = "plcr-client-an2-web"
  user_pool_id = aws_cognito_user_pool.seoul.id
  
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
  
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30
  
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  
  callback_urls = [
    "https://megaticket.click/callback",
    "https://seoul.megaticket.click/callback"
  ]
  
  logout_urls = [
    "https://megaticket.click",
    "https://seoul.megaticket.click"
  ]
}

resource "aws_cognito_user_pool_domain" "seoul" {
  domain       = "plcr-auth-seoul"
  user_pool_id = aws_cognito_user_pool.seoul.id
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_cognito_pre_signup" {
  statement_id  = "AllowCognitoPreSignup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_signup_seoul.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.seoul.arn
}

resource "aws_lambda_permission" "allow_cognito_migration" {
  statement_id  = "AllowCognitoMigration"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_migration_seoul.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.seoul.arn
}
