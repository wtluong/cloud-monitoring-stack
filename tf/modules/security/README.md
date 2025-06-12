# Security Module

This module creates security groups for the cloud monitoring infrastructure, implementing secure access controls for the bastion host.

## Features

- ✅ Bastion host security group with SSH access control
- ✅ Automatic public IP detection (no manual IP updates needed!)
- ✅ Manual IP override option
- ✅ Consistent tagging with other modules

## Architecture

```
Your Computer (Dynamic IP)
       │
       │ Automatic IP Detection
       │ via get_my_ip.sh
       ↓
┌─────────────────────┐
│   Internet          │
└─────────┬───────────┘
          │ SSH (22)
          ↓
┌─────────────────────┐
│ Bastion Security    │
│ Group               │
├─────────────────────┤
│ Ingress Rules:      │
│ • SSH (22) from     │
│   your current IP   │
│                     │
│ Egress Rules:       │
│ • All traffic       │
│   (0.0.0.0/0)       │
└─────────────────────┘
```

## Usage

### Basic Usage (with Automatic IP Detection)

```hcl
# environments/dev/main.tf
locals {
  name_prefix = "dev-monitoring"
  my_ip_cidr  = coalesce(var.my_ip_cidr, data.external.my_ip.result["ip"])
}

# Get current public IP automatically
data "external" "my_ip" {
  program = ["${path.module}/get_my_ip.sh"]
}

# Optional: Allow manual override
variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation"
  type        = string
  default     = ""
}

module "security" {
  source = "../../modules/security"
  
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [local.my_ip_cidr]
  common_tags       = local.common_tags
}
```

### The get_my_ip.sh Script

Create this script in your environment directory:

```bash
#!/bin/bash
# File: tf/environments/dev/get_my_ip.sh

# Get public IP and format for Terraform
IP=$(curl -s ifconfig.me)
echo "{\"ip\": \"${IP}/32\"}"
```

Make it executable:
```bash
chmod +x tf/environments/dev/get_my_ip.sh
```

### Manual IP Override

If you need to specify a different IP:

```bash
# Option 1: Via terraform.tfvars
echo 'my_ip_cidr = "203.0.113.0/32"' > terraform.tfvars

# Option 2: Via command line
terraform apply -var="my_ip_cidr=203.0.113.0/32"
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for all resource names | string | - | yes |
| vpc_id | ID of the VPC where security groups will be created | string | - | yes |
| allowed_ssh_cidrs | List of CIDR blocks allowed to SSH to bastion | list(string) | - | yes |
| common_tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion_security_group_id | ID of the bastion host security group |

## Security Group Details

### Created Security Group

**Name**: `{name_prefix}-bastion-sg` (e.g., `dev-monitoring-bastion-sg`)

**Rules**:

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| Ingress | TCP | 22 | Your IP/32 | SSH access from your current public IP |
| Egress | All | All | 0.0.0.0/0 | Allow all outbound traffic |

## Automatic IP Detection Details

The automatic IP detection uses Terraform's `external` data source to run a shell script that:

1. Queries `ifconfig.me` to get your current public IP
2. Formats it as JSON with `/32` CIDR notation
3. Returns it to Terraform

Benefits:
- ✅ No manual IP updates when your IP changes
- ✅ Works with dynamic home IPs
- ✅ Automatically updates security group on `terraform apply`

## Troubleshooting

### Script Execution Issues

If the IP detection fails:

1. **Check script permissions**:
   ```bash
   ls -la tf/environments/dev/get_my_ip.sh
   # Should show executable permissions (x)
   ```

2. **Test the script manually**:
   ```bash
   ./tf/environments/dev/get_my_ip.sh
   # Should output: {"ip": "YOUR_IP/32"}
   ```

3. **Check curl is installed**:
   ```bash
   which curl
   # If not found, install curl
   ```

4. **Alternative IP services**:
   If `ifconfig.me` is down, update the script to use:
   - `curl -s api.ipify.org`
   - `curl -s icanhazip.com`
   - `curl -s checkip.amazonaws.com`

### Security Group Not Updating

If your IP changed but the security group didn't update:

1. Force a refresh:
   ```bash
   terraform apply -refresh=true
   ```

2. Check current security group rules:
   ```bash
   aws ec2 describe-security-groups --group-ids $(terraform output -raw bastion_security_group_id)
   ```

## Testing the Security Group

1. **Verify in AWS Console**:
   - Navigate to EC2 → Security Groups
   - Find `dev-monitoring-bastion-sg`
   - Check inbound rules show your current IP

2. **Check what IP Terraform detected**:
   ```bash
   terraform console
   > local.my_ip_cidr
   "YOUR_IP/32"
   ```

## Cost

Security Groups are **FREE**. No charges for:
- Creating security groups
- Rules within security groups
- Rule evaluations

## Best Practices

1. **Regular Reviews**: Even with auto-detection, periodically review access
2. **Least Privilege**: Only SSH access, only from your IP
3. **No Hardcoded IPs**: The auto-detection prevents hardcoded IPs in code
4. **Version Control**: Don't commit `terraform.tfvars` with IPs

## Future Enhancements

This module can be extended to include:

1. **Monitoring Security Group** (when needed):
   ```hcl
   resource "aws_security_group" "monitoring" {
     # SSH from bastion
     # Prometheus (9090) from bastion
     # Grafana (3000) from bastion
   }
   ```

2. **Multiple Allowed IPs**:
   ```hcl
   allowed_ssh_cidrs = [
     local.my_ip_cidr,
     "203.0.113.0/32",  # Office IP
     "198.51.100.0/24"  # VPN range
   ]
   ```

3. **Application Load Balancer Security Group** (much later)

## Example: Complete Environment Setup

```hcl
# environments/dev/main.tf
locals {
  name_prefix = "dev-monitoring"
  environment = "dev"
  common_tags = {
    Environment = local.environment
    Project     = "cloud-monitoring"
    ManagedBy   = "terraform"
  }
  my_ip_cidr = coalesce(var.my_ip_cidr, data.external.my_ip.result["ip"])
}

data "external" "my_ip" {
  program = ["${path.module}/get_my_ip.sh"]
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation (optional override)"
  type        = string
  default     = ""
}

module "vpc" {
  source      = "../../modules/vpc"
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

module "security" {
  source            = "../../modules/security"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [local.my_ip_cidr]
  common_tags       = local.common_tags
}
```

## Next Steps

1. ✅ Security group is created with your current IP
2. Next: Create IAM roles for EC2 instances
3. Then: Launch bastion EC2 instance using this security group
4. Later: Add monitoring security group when needed
