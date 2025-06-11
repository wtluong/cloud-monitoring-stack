# Cloud Monitoring Stack

A complete Infrastructure as Code (IaC) solution for deploying a monitoring stack on AWS using Terraform. This project creates a secure, scalable monitoring infrastructure with bastion host access and dedicated monitoring services.

## 🏗️ Architecture

```
Internet Gateway
        │
        ▼
┌─────────────────┐    ┌─────────────────┐
│   Public Subnet │    │  Private Subnet │
│                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Bastion  │  │    │  │Monitoring │  │
│  │   Host    │  │────┤  │  Server   │  │
│  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │
└─────────────────┘    └─────────────────┘
        │                       │
        ▼                       ▼
  Internet Access        NAT Gateway
                        (for updates)
```

## 📋 Components

### Infrastructure Modules
- **VPC Module**: Virtual Private Cloud with public/private subnets
- **Security Module**: Security groups with least-privilege access
- **IAM Module**: Roles and policies for EC2 instances
- **Compute Module**: EC2 instances (bastion + monitoring)

### Security Features
- Bastion host for secure SSH access
- Private subnet for monitoring server
- Security groups restricting access by port and source
- Encrypted EBS volumes
- IAM roles instead of hardcoded credentials

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- SSH key pair for instance access

### Deployment

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd cloud-monitoring-stack/tf/environments/dev
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and customize variables:**
   ```bash
   # Edit main.tf to update:
   # - Your SSH public key path
   # - Any other configuration preferences
   ```

4. **Plan and apply:**
   ```bash
   terraform plan -out=plan.tfplan
   terraform apply plan.tfplan
   ```

5. **Get connection information:**
   ```bash
   terraform output
   ```

## 🔧 Configuration

### Environment Structure
```
tf/
├── environments/
│   ├── dev/                 # Development environment
│   │   ├── main.tf         # Environment configuration
│   │   ├── outputs.tf      # Output definitions
│   │   ├── providers.tf    # Provider configuration
│   │   └── terraform.tf    # Terraform settings
│   └── prod/               # Production environment (future)
└── modules/
    ├── vpc/                # VPC module
    ├── security/           # Security groups module
    ├── iam/               # IAM roles module
    └── compute/           # EC2 instances module
```

### Key Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `enable_nat_gateway` | Enable NAT for private subnets | `true` |
| `bastion_instance_type` | Bastion host instance type | `t3.micro` |
| `monitoring_instance_type` | Monitoring server instance type | `t3.medium` |

## 🔐 Access and Security

### SSH Access
1. **Connect to bastion host:**
   ```bash
   ssh ec2-user@<bastion-public-ip>
   ```

2. **Connect to monitoring server via bastion:**
   ```bash
   ssh -o ProxyJump=ec2-user@<bastion-public-ip> ec2-user@<monitoring-private-ip>
   ```

3. **Or use SSH config for easier access:**
   ```bash
   # Add to ~/.ssh/config
   Host bastion
       HostName <bastion-public-ip>
       User ec2-user
       IdentityFile ~/.ssh/your-key

   Host monitoring
       HostName <monitoring-private-ip>
       User ec2-user
       ProxyJump bastion
   ```

### Security Groups
- **Bastion**: SSH (22) from your IP only
- **Monitoring**: SSH (22) from bastion, monitoring ports (3000, 9090, 9100) from bastion

## 📊 Monitoring Stack Installation

The instances are deployed with minimal configuration. To install monitoring services:

### Option 1: Manual Installation (Recommended)
```bash
# SSH to monitoring instance
ssh monitoring  # (if using SSH config)

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Install monitoring services as needed:
# - Prometheus
# - Grafana
# - Node Exporter
# - CloudWatch Agent
```

### Option 2: Access via SSH Tunnels
```bash
# Create tunnels for web access
ssh -L 3000:<monitoring-private-ip>:3000 -L 9090:<monitoring-private-ip>:9090 ec2-user@<bastion-public-ip>

# Then access:
# - Grafana: http://localhost:3000
# - Prometheus: http://localhost:9090
```

## 🗂️ File Structure

```
cloud-monitoring-stack/
├── README.md
└── tf/
    ├── environments/
    │   └── dev/
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── providers.tf
    │       ├── terraform.tf
    │       └── get_my_ip.sh
    └── modules/
        ├── vpc/
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── README.md
        ├── security/
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── README.md
        ├── iam/
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── README.md
        └── compute/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── README.md
            └── user-data/
                ├── bastion.sh
                └── monitoring.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission denied on SSH:**
   - Ensure your SSH key matches the public key in Terraform
   - Check security group rules allow your IP

2. **Can't reach monitoring instance:**
   - Verify NAT Gateway is enabled for private subnet internet access
   - Check security groups allow traffic from bastion

3. **Terraform apply fails:**
   - Ensure AWS credentials are configured
   - Check AWS service limits and quotas

### Debug Commands
```bash
# Check terraform state
terraform show

# View terraform outputs
terraform output

# Validate configuration
terraform validate

# Check AWS resources
aws ec2 describe-instances --filters "Name=tag:Project,Values=cloud-monitoring"
```

## 💰 Cost Considerations

Estimated monthly costs (us-west-2):
- **t3.micro bastion**: ~$8.50/month
- **t3.medium monitoring**: ~$30/month  
- **NAT Gateway**: ~$45/month + data transfer
- **EBS volumes**: ~$10/month
- **Elastic IP**: ~$3.65/month

**Total**: ~$97/month (costs may vary by region and usage)

## 🚧 Future Enhancements

- [ ] Add production environment
- [ ] Implement monitoring stack automation
- [ ] Add SSL/TLS certificates
- [ ] Implement log aggregation
- [ ] Add alerting configuration
- [ ] Multi-region deployment
- [ ] Auto-scaling groups
