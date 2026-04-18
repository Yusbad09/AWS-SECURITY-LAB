# ec2.tf
# ─────────────────────────────────────────────────────────────────
# This file creates:
#   - A Security Group (virtual firewall for your EC2 instance)
#   - An IAM Role (gives the EC2 instance permissions to call AWS APIs)
#   - An EC2 Instance (your virtual server)
#
# Security Group rules follow least-privilege:
#   Inbound:  Only SSH (port 22) from your IP
#   Outbound: Only HTTPS (443) for updates/patches
# ─────────────────────────────────────────────────────────────────

# ── SECURITY GROUP ────────────────────────────────────────────────
# Think of this as a firewall rule set attached to your EC2 instance
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for lab EC2 instance - least privilege"
  vpc_id      = aws_vpc.main.id

  # ── INBOUND RULES ──
  # Only allow SSH from a specific IP (your IP address)
  ingress {
    description = "SSH access - restrict to your IP in production"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # ── OUTBOUND RULES ──
  # Allow HTTPS outbound only — for OS updates and AWS API calls
  egress {
    description = "HTTPS outbound for updates and AWS API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP outbound — needed for some package managers
  egress {
    description = "HTTP outbound for package updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── IAM ROLE FOR EC2 ──────────────────────────────────────────────
# This gives the EC2 instance an identity in AWS so it can
# interact with other AWS services (like writing to CloudWatch logs)
# without needing hardcoded credentials on the server

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust policy: allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"   # Only EC2 can assume this role
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Attach CloudWatch policy — allows EC2 to send logs to CloudWatch
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach SSM policy — allows AWS Systems Manager access (no SSH needed)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile — wraps the IAM role so EC2 can use it
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ── DATA SOURCE: LATEST AMAZON LINUX 2 AMI ───────────────────────
# Instead of hardcoding an AMI ID (which changes by region),
# this automatically finds the latest Amazon Linux 2 image
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── EC2 INSTANCE ──────────────────────────────────────────────────
resource "aws_instance" "lab" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type       # t2.micro = free tier
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Encrypt the root volume — security best practice
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20           # GB
    encrypted             = true         # Encrypt at rest
    delete_on_termination = true
  }

  # User data: runs on first boot — basic hardening
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-cloudwatch-agent
    # Disable root SSH login
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    # Disable password authentication (key-based only)
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  tags = {
    Name        = "${var.project_name}-lab-instance"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
