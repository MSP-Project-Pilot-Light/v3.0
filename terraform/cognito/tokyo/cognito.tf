# Cognito User Pool (Tokyo)
resource "aws_cognito_user_pool" "tokyo" {
  name = "plcr-pool-an1-auth"
  
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
    pre_sign_up         = aws_lambda_function.pre_signup_tokyo.arn
    user_migration      = aws_lambda_function.user_migration_tokyo.arn
    pre_authentication  = aws_lambda_function.pre_auth_tokyo.arn
  }
}

resource "aws_cognito_user_pool_client" "tokyo_web" {
  name         = "plcr-client-an1-web"
  user_pool_id = aws_cognito_user_pool.tokyo.id
  
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
    "https://tokyo.megaticket.click/callback"
  ]
  
  logout_urls = [
    "https://tokyo.megaticket.click"
  ]
}

resource "aws_cognito_user_pool_domain" "tokyo" {
  domain       = "plcr-auth-tokyo"
  user_pool_id = aws_cognito_user_pool.tokyo.id
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_cognito_pre_signup" {
  statement_id  = "AllowCognitoPreSignup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_signup_tokyo.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.tokyo.arn
}

resource "aws_lambda_permission" "allow_cognito_migration" {
  statement_id  = "AllowCognitoMigration"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_migration_tokyo.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.tokyo.arn
}
