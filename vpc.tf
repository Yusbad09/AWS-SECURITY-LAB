# vpc.tf
# ─────────────────────────────────────────────────────────────────
# This file builds your network foundation:
#   - VPC (your private isolated network in AWS)
#   - Public subnet (for resources that need internet access)
#   - Private subnet (for internal resources — databases, app servers)
#   - Internet Gateway (allows public subnet to reach the internet)
#   - Route Tables (define where network traffic goes)
#
# Think of it like this:
#   VPC = your office building
#   Public subnet = reception area (anyone can reach it)
#   Private subnet = server room (only internal staff can access)
#   Internet Gateway = the front door
#   Route tables = the signs directing traffic
# ─────────────────────────────────────────────────────────────────

# ── VPC ──────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true           # Allows EC2 instances to get DNS names
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── PUBLIC SUBNET ─────────────────────────────────────────────────
# Resources here can have public IPs and reach the internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true        # EC2 instances here get a public IP automatically

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
    Type        = "Public"
    ManagedBy   = "Terraform"
  }
}

# ── PRIVATE SUBNET ────────────────────────────────────────────────
# Resources here have NO direct internet access — more secure
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Environment = var.environment
    Type        = "Private"
    ManagedBy   = "Terraform"
  }
}

# ── INTERNET GATEWAY ──────────────────────────────────────────────
# The front door — connects your VPC to the public internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── PUBLIC ROUTE TABLE ────────────────────────────────────────────
# Tells the public subnet: "send internet traffic through the gateway"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"           # All traffic (0.0.0.0/0 = everywhere)
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── PRIVATE ROUTE TABLE ───────────────────────────────────────────
# Private subnet has no internet route — traffic stays internal only
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
