# variables.tf
# ─────────────────────────────────────────────────────────────────
# Variables are like parameters for your infrastructure.
# Define them here, set their values in terraform.tfvars.
# This keeps your config flexible and reusable.
# ─────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources — makes them easy to identify in AWS console"
  type        = string
  default     = "yusuf-security-lab"
}

variable "environment" {
  description = "Environment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC — defines the IP address range"
  type        = string
  default     = "10.0.0.0/16"           # 65,536 available IP addresses
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (internet-accessible)"
  type        = string
  default     = "10.0.1.0/24"           # 256 addresses, internet-facing
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (no direct internet access)"
  type        = string
  default     = "10.0.2.0/24"           # 256 addresses, internal only
}

variable "allowed_ssh_cidr" {
  description = "Your IP address allowed to SSH into the EC2 instance. Use your actual IP."
  type        = string
  default     = "0.0.0.0/0"             # WARNING: restrict this to your IP in production
}

variable "instance_type" {
  description = "EC2 instance type - t3.micro is free tier eligible"
  type        = string
  default     = "t3.micro"
}
