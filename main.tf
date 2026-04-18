# main.tf
# ─────────────────────────────────────────────────────────────────
# This is the entry point for your Terraform project.
# It tells Terraform:
#   1. Which cloud provider to use (AWS)
#   2. Which version of Terraform and the AWS provider are required
#   3. Which AWS region to deploy everything into
# ─────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.0"          # Minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"               # Use AWS provider version 5.x
    }
  }
}

# Configure the AWS provider
# Terraform will use the credentials you set up with "aws configure"
provider "aws" {
  region = var.aws_region
}
