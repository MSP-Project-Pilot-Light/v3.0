# =============================================================================
# IAM Roles and Policies - Seoul Main Region (V3.0)
# =============================================================================

# -----------------------------------------------------------------------------
# EC2 IAM Role (SSM + DynamoDB + Bedrock + CloudWatch)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-role-${var.region_code}-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-role-${var.region_code}-ec2"
  }
}

# -----------------------------------------------------------------------------
# SSM 관리형 정책 연결
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------------------------------------------------------
# Bedrock 액세스 정책 (인라인) - Converse API + Cross-Region Inference
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "bedrock_policy" {
  name = "${var.project_name}-pol-${var.region_code}-bedrock"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockInvokeAndConverse"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:Converse",
          "bedrock:ConverseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/anthropic.*",
          "arn:aws:bedrock:*::foundation-model/amazon.*",
          "arn:aws:bedrock:*:*:inference-profile/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# DynamoDB 최소 권한 정책
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "${var.project_name}-pol-${var.region_code}-gtbl"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBMinimalAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:TransactWriteItems",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:626614672806:table/${var.dynamodb_table_prefix}-*",
          "arn:aws:dynamodb:${var.aws_region}:626614672806:table/${var.dynamodb_table_prefix}-*/index/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Logs 정책
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.project_name}-pol-${var.region_code}-lsm"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# S3 아티팩트 버킷 접근 정책 (CodeDeploy Agent용)
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "s3_artifacts_policy" {
  name = "${var.project_name}-pol-${var.region_code}-s3-artifacts"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ArtifactsAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::plcr-s3-an2-app-artifacts",
          "arn:aws:s3:::plcr-s3-an2-app-artifacts/*",
          "arn:aws:s3:::aws-codedeploy-ap-northeast-2/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# ✅ (추가) EC2 → S3 로그 버킷 업로드 권한 (plcr-s3-an2-log/ec2/*)
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy" "s3_log_write_policy" {
  name = "${var.project_name}-pol-${var.region_code}-s3-log-write"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 업로드 권한
      {
        Sid    = "AllowPutLogObjects"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = "arn:aws:s3:::plcr-s3-an2-log/ec2/*"
      },

      # (선택이지만 추천) prefix 범위 내 list 권한 (SDK/CLI가 내부적으로 list 쓰는 경우 대비)
      {
        Sid    = "AllowListLogBucketPrefix"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::plcr-s3-an2-log"
        Condition = {
          StringLike = {
            "s3:prefix" = ["ec2/*"]
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Instance Profile
# -----------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-insp-${var.region_code}-ec2"
  role = aws_iam_role.ec2_role.name
}
