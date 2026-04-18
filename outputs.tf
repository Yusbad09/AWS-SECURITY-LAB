# outputs.tf
# ─────────────────────────────────────────────────────────────────
# Outputs display useful information after Terraform deploys.
# Think of them as the summary printed at the end of a deployment.
# ─────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 lab instance"
  value       = aws_instance.lab.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.lab.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.lab.private_ip
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.main.id
}

output "flow_logs_group" {
  description = "CloudWatch log group for VPC flow logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "lab_summary" {
  description = "Summary of deployed resources"
  value = <<-EOT
    ═══════════════════════════════════════════
    AWS Security Lab — Deployed Successfully
    ═══════════════════════════════════════════
    VPC ID         : ${aws_vpc.main.id}
    EC2 Public IP  : ${aws_instance.lab.public_ip}
    GuardDuty      : ENABLED
    Security Hub   : ENABLED
    VPC Flow Logs  : ENABLED
    ═══════════════════════════════════════════
  EOT
}
