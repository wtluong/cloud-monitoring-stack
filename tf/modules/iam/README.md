# IAM Module

This module creates IAM roles and policies for EC2 instances in the cloud monitoring infrastructure.

## Features

- ✅ IAM role for EC2 instances
- ✅ Instance profile for attaching role to EC2
- ✅ Optional CloudWatch logs permissions
- ✅ Optional Systems Manager (SSM) access
- ✅ Follows principle of least privilege

## What This Creates

```
┌─────────────────────────────────────┐
│          IAM Role                   │
│   (dev-monitoring-ec2-role)         │
│                                     │
│   Trust Policy:                     │
│   - EC2 service can assume role    │
│                                     │
│   Permissions:                      │
│   - CloudWatch logs (optional)     │
│   - SSM access (optional)          │
└────────────┬───────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│      Instance Profile               │
│  (dev-monitoring-ec2-profile)       │
│                                     │
│  Attached to EC2 instances         │
│  Links role to instance            │
└─────────────────────────────────────┘
```

## Usage

### Basic Usage

```hcl
module "iam" {
  source = "../../modules/iam"
  
  name_prefix = "dev-monitoring"
  
  # Use defaults for other values
}
```

### Advanced Usage

```hcl
module "iam" {
  source = "../../modules/iam"
  
  name_prefix = "prod-monitoring"
  
  # Enable all features
  enable_cloudwatch_logs = true
  enable_ssm_access     = true
  
  common_tags = {
    Environment = "production"
    CostCenter  = "engineering"
  }
}
```

### Using in Compute Module

```hcl
# In your compute module or environment
resource "aws_instance" "monitoring" {
  # ... other configuration ...
  
  # Attach the IAM role
  iam_instance_profile = module.iam.ec2_instance_profile_name
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for all resource names | string | - | yes |
| enable_cloudwatch_logs | Enable CloudWatch logs permissions | bool | true | no |
| enable_ssm_access | Enable Systems Manager access | bool | false | no |
| common_tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2_role_name | Name of the IAM role |
| ec2_role_arn | ARN of the IAM role |
| ec2_instance_profile_name | Name of the instance profile (use this for EC2) |
| ec2_instance_profile_arn | ARN of the instance profile |
| iam_summary | Summary of IAM configuration |

## IAM Permissions Explained

### Default Permissions (CloudWatch Logs Enabled)

When `enable_cloudwatch_logs = true` (default), instances can:
- Write custom metrics to CloudWatch
- Create log groups and streams
- Send logs to CloudWatch Logs

This allows your monitoring server to:
- Send Prometheus metrics to CloudWatch (optional)
- Store application logs centrally
- Track instance performance

### Optional SSM Permissions

When `enable_ssm_access = true`, instances can:
- Be accessed via AWS Systems Manager Session Manager
- No SSH keys needed
- Access is logged and auditable

## Security Best Practices

1. **Least Privilege**: Only grants necessary permissions
2. **No Hardcoded Credentials**: Uses IAM roles instead of access keys
3. **Separate Roles**: Each instance type can have its own role if needed
4. **Audit Trail**: All actions are logged in CloudTrail

## Cost

IAM roles and policies are **FREE**. No charges for:
- Creating IAM roles
- Creating IAM policies
- Attaching roles to EC2 instances

## Common Issues

### Instance Can't Write to CloudWatch
1. Verify `enable_cloudwatch_logs = true`
2. Check instance has internet access (or VPC endpoint)
3. Verify instance profile is attached

### Can't Access Instance via SSM
1. Ensure `enable_ssm_access = true`
2. SSM agent must be installed (included in Amazon Linux 2)
3. Instance needs internet access or VPC endpoints

## Examples

### Example 1: Development Environment (Basic)

```hcl
# Simple setup with defaults
module "iam" {
  source = "../../modules/iam"
  
  name_prefix = "dev-monitoring"
}
```

### Example 2: Production with All Features

```hcl
module "iam" {
  source = "../../modules/iam"
  
  name_prefix = "prod-monitoring"
  
  enable_cloudwatch_logs = true
  enable_ssm_access     = true
  
  common_tags = {
    Environment = "production"
    Compliance  = "required"
  }
}
```

### Example 3: Using with Environment

```hcl
# In environments/dev/main.tf
locals {
  name_prefix = "dev-monitoring"
}

module "iam" {
  source = "../../modules/iam"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# Later in compute module
module "compute" {
  source = "../../modules/compute"
  
  instance_profile_name = module.iam.ec2_instance_profile_name
  # ... other configuration
}
```

## Why Instance Profiles?

EC2 instances can't directly use IAM roles. They need an "instance profile" which is a container for the role. This module handles that complexity for you:

```
IAM Role → Instance Profile → EC2 Instance
```

## Testing IAM Permissions

After deploying:

1. **Check role is attached**:
   ```bash
   aws ec2 describe-instances --instance-ids <instance-id> \
     --query 'Reservations[0].Instances[0].IamInstanceProfile'
   ```

2. **Test CloudWatch access** (from instance):
   ```bash
   aws cloudwatch put-metric-data \
     --namespace "Custom/Test" \
     --metric-name "TestMetric" \
     --value 1
   ```

3. **Test SSM access** (if enabled):
   ```bash
   aws ssm start-session --target <instance-id>
   ```

## Next Steps

1. Apply this module to create IAM resources
2. Use the instance profile in your compute module
3. Test permissions work as expected
