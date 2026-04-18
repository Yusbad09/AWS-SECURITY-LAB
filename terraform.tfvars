# terraform.tfvars
# ─────────────────────────────────────────────────────────────────
# This file sets the actual values for your variables.
# It overrides the defaults in variables.tf.
#
# ⚠️ This file is in .gitignore — never commit it if it contains
# sensitive values like your IP address.
# ─────────────────────────────────────────────────────────────────

aws_region          = "us-east-1"
project_name        = "yusuf-security-lab"
environment         = "dev"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
instance_type       = "t3.micro"

# ⚠️ IMPORTANT: Replace with your actual IP address for security
# Find your IP at: https://whatismyipaddress.com
# Format: "YOUR.IP.ADDRESS.HERE/32"   (/32 means exactly this one IP)
allowed_ssh_cidr    = "0.0.0.0/0"
