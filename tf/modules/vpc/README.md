# VPC Module

This module creates a VPC with public and private subnets across multiple availability zones.

## Features

- ✅ VPC with customizable CIDR block
- ✅ Public subnets with internet access
- ✅ Private subnets (isolated by default)
- ✅ Optional NAT Gateway for private subnet internet access
- ✅ Proper tagging for resource identification
- ✅ Multi-AZ support for high availability

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   VPC                           │
│                                                 │
│  ┌──────────────┐        ┌──────────────┐     │
│  │Public Subnet │        │Public Subnet │     │
│  │    AZ-1      │        │    AZ-2      │     │
│  └──────┬───────┘        └──────┬───────┘     │
│         │                        │              │
│         └────────┬───────────────┘              │
│                  │                              │
│           [Internet Gateway]                    │
│                  │                              │
│     ┌────────────┴────────────┐                │
│     │   [NAT Gateway]         │                │
│     │   (Optional)            │                │
│     └────────────┬────────────┘                │
│                  │                              │
│  ┌──────────────┐│        ┌──────────────┐     │
│  │Private Subnet││        │Private Subnet│     │
│  │    AZ-1      ││        │    AZ-2      │     │
│  └──────────────┘         └──────────────┘     │
└─────────────────────────────────────────────────┘
```

## Usage

### Basic Usage (Development)

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix = "dev-monitoring"
  
  # Optional: Use defaults for other values
}
```

### Advanced Usage (Production)

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix          = "prod-monitoring"
  vpc_cidr            = "10.100.0.0/16"
  availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  public_subnet_cidrs = [
    "10.100.1.0/24",
    "10.100.2.0/24",
    "10.100.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.100.10.0/24",
    "10.100.20.0/24",
    "10.100.30.0/24"
  ]
  
  enable_nat_gateway = true  # Enable for production
  
  common_tags = {
    Environment = "production"
    CostCenter  = "engineering"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for all resource names | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/16" | no |
| availability_zones | List of AZs to use | list(string) | ["us-west-2a", "us-west-2b"] | no |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | no |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | ["10.0.10.0/24", "10.0.20.0/24"] | no |
| enable_nat_gateway | Enable NAT Gateway (costs money!) | bool | false | no |
| common_tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| first_public_subnet_id | ID of first public subnet (for bastion) |
| first_private_subnet_id | ID of first private subnet |
| nat_gateway_id | ID of NAT Gateway (if enabled) |
| vpc_summary | Summary of VPC configuration |

## Cost Considerations

- **VPC**: Free
- **Subnets**: Free
- **Internet Gateway**: Free
- **NAT Gateway**: ~$0.045/hour (~$33/month) + data charges
- **Elastic IP**: Free when attached, ~$0.005/hour when not

## Examples

### Example 1: Development Environment (Minimal Cost)

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix = "dev-monitoring"
  # NAT Gateway disabled by default
}
```

### Example 2: Production Environment (High Availability)

```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix         = "prod-monitoring"
  enable_nat_gateway = true
  
  # Use 3 AZs for better availability
  availability_zones = data.aws_availability_zones.available.names
  
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24", 
    "10.0.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.20.0/24",
    "10.0.30.0/24"
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}
```

## Notes

1. **NAT Gateway**: Disabled by default to save costs during development
2. **Subnet Sizing**: /24 subnets provide 256 IPs each (AWS reserves 5)
3. **Multi-AZ**: Always use at least 2 AZs for production
4. **CIDR Planning**: Plan your CIDR blocks to avoid conflicts with other VPCs
