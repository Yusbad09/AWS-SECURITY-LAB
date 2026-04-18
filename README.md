# 🔐 AWS Security Lab — Infrastructure as Code with Terraform

A production-style AWS security lab built entirely with Terraform, demonstrating secure cloud infrastructure deployment following AWS security best practices and least-privilege principles.

Built as a hands-on DevSecOps portfolio project to demonstrate Infrastructure as Code (IaC) skills alongside cloud security engineering experience.

---

## 🏗️ What Gets Deployed

| Resource | Description |
|---|---|
| **VPC** | Isolated network with custom CIDR block |
| **Public Subnet** | Internet-accessible subnet for the EC2 instance |
| **Private Subnet** | Internal-only subnet for future private resources |
| **Internet Gateway** | Connects the public subnet to the internet |
| **Route Tables** | Public and private routing with proper separation |
| **Security Group** | Least-privilege firewall — SSH in, HTTPS/HTTP out only |
| **EC2 Instance** | Hardened Amazon Linux 2, encrypted root volume, no root SSH |
| **IAM Role** | Instance profile with CloudWatch and SSM permissions only |
| **GuardDuty** | AI-powered threat detection with S3 and malware scanning |
| **Security Hub** | Centralised findings with AWS FSBP and CIS benchmarks |
| **VPC Flow Logs** | Full network traffic capture to CloudWatch (30-day retention) |

---

## 🗂️ Project Structure

```
aws-security-lab/
├── main.tf           # Provider configuration
├── variables.tf      # Variable declarations
├── terraform.tfvars  # Variable values (git-ignored)
├── vpc.tf            # VPC, subnets, route tables, internet gateway
├── ec2.tf            # Security group, IAM role, EC2 instance
├── security.tf       # GuardDuty, Security Hub, VPC Flow Logs
├── outputs.tf        # Deployment summary and resource IDs
└── .gitignore
```

---

## 🔐 Security Decisions

| Decision | Reason |
|---|---|
| Private subnet with no internet route | Least-privilege network segmentation |
| Security group — SSH inbound restricted by IP | Prevents brute force from arbitrary IPs |
| EC2 root volume encrypted | Data at rest protection |
| Root SSH login disabled via user_data | Prevents root-level remote access |
| Password auth disabled — key-based only | Eliminates credential brute force risk |
| IAM role scoped to CloudWatch + SSM only | Least-privilege — no overly permissive policies |
| GuardDuty with S3 + malware scanning enabled | Threat detection across compute and storage |
| CIS Benchmark + AWS FSBP standards in Security Hub | Automated compliance checking against 200+ controls |
| VPC Flow Logs — ALL traffic captured | Full network visibility for incident investigation |

---

## ⚙️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account (free tier sufficient for this lab)

---

## 🚀 Deployment

### 1. Clone the repository
```bash
git clone https://github.com/yusbad09/aws-security-lab.git
cd aws-security-lab
```

### 2. Configure your variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your IP address:
```hcl
allowed_ssh_cidr = "YOUR.IP.ADDRESS/32"
```
Find your IP at https://whatismyipaddress.com

### 3. Initialise Terraform
```bash
terraform init
```
This downloads the AWS provider plugin.

### 4. Preview what will be deployed
```bash
terraform plan
```
Review the output carefully — this shows exactly what Terraform will create.

### 5. Deploy
```bash
terraform apply
```
Type `yes` when prompted. Deployment takes approximately 2-3 minutes.

### 6. View outputs
```bash
terraform output lab_summary
```

---

## 🧹 Tear Down (Important — avoid AWS charges)

When you are done with the lab, destroy all resources to avoid charges:
```bash
terraform destroy
```
Type `yes` when prompted. This removes everything Terraform created.

---

## 💡 Key Terraform Concepts Demonstrated

| Concept | Where Used |
|---|---|
| `resource` blocks | All `.tf` files — declaring AWS resources |
| `variable` + `tfvars` | `variables.tf` + `terraform.tfvars` |
| `data` sources | `ec2.tf` — dynamic AMI lookup |
| `output` values | `outputs.tf` — post-deployment summary |
| `depends_on` | `security.tf` — controlling resource creation order |
| `jsonencode()` | `ec2.tf`, `security.tf` — IAM policy documents |
| Resource tagging | All resources — consistent `Name`, `Environment`, `ManagedBy` tags |
| `user_data` | `ec2.tf` — automated instance hardening on boot |

---

## 📌 Real-World Context

This lab reflects the same security principles applied in enterprise environments managing cloud infrastructure at scale — VPC segmentation, least-privilege IAM, native AWS threat detection, and full network visibility through flow logs. All aligned with AWS Well-Architected Framework security pillar guidelines.

---

## 🛡️ Related Skills

`Terraform` · `AWS` · `IaC` · `DevSecOps` · `VPC Design` · `IAM` · `GuardDuty` · `Security Hub` · `CloudWatch` · `EC2 Hardening` · `Network Security`

---

## 📄 License

MIT License — free to use and adapt with attribution.

---

## 👤 Author

**Yusuf Akinkunmi Badrudeen**
Cybersecurity & Cloud Security Engineer
[LinkedIn](https://www.linkedin.com/in/badrudeen-yusuf-akinkunmi-6692b819b/) · [Portfolio](https://yusbad09.github.io/)
