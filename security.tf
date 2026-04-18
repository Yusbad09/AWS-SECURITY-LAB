# security.tf
# ─────────────────────────────────────────────────────────────────
# GuardDuty and Security Hub are commented out below.
# These services require full AWS account activation (up to 24hrs
# for new accounts). Uncomment and run "terraform apply" again
# once your account is fully active.
#
# VPC Flow Logs are enabled immediately — no subscription needed.
# ─────────────────────────────────────────────────────────────────

# ── GUARDDUTY ─────────────────────────────────────────────────────
# Uncomment once your AWS account is fully activated
# resource "aws_guardduty_detector" "main" {
#   enable = true
#   datasources {
#     s3_logs {
#       enable = true
#     }
#     malware_protection {
#       scan_ec2_instance_with_findings {
#         ebs_volumes {
#           enable = true
#         }
#       }
#     }
#   }
#   tags = {
#     Name        = "${var.project_name}-guardduty"
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#   }
# }

# ── SECURITY HUB ──────────────────────────────────────────────────
# Uncomment once your AWS account is fully activated
# resource "aws_securityhub_account" "main" {}
#
# resource "aws_securityhub_standards_subscription" "aws_foundational" {
#   depends_on    = [aws_securityhub_account.main]
#   standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
# }
#
# resource "aws_securityhub_standards_subscription" "cis" {
#   depends_on    = [aws_securityhub_account.main]
#   standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"
# }
#
# resource "aws_securityhub_product_subscription" "guardduty" {
#   depends_on  = [aws_securityhub_account.main]
#   product_arn = "arn:aws:securityhub:${var.aws_region}::product/aws/guardduty"
# }

# ── VPC FLOW LOGS ─────────────────────────────────────────────────
# Captures all network traffic metadata in your VPC
# No subscription needed — works on all accounts immediately

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.project_name}-flow-logs"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.project_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${var.project_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  vpc_id          = aws_vpc.main.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name        = "${var.project_name}-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
