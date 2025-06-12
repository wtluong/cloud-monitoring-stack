# Common values using locals
locals {
  name_prefix = "dev-monitoring"
  environment = "dev"
  
  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    Project     = "cloud-monitoring"
    ManagedBy   = "terraform"
  }

  my_ip_cidr = coalesce(var.my_ip_cidr, data.external.my_ip.result["ip"])
}

# Public IP for Security Module; specifically Bastion host
data "external" "my_ip" {
  program = ["${path.module}/get_my_ip.sh"]
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation"
  type        = string
  default     = ""
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  enable_nat_gateway = true # required for monitoring instance to reach internet & download packages
}

# Security Module
module "security" {
  source = "../../modules/security"
  
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [local.my_ip_cidr]
  common_tags       = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  common_tags = local.common_tags

  # Optional: Enable SSM
  enable_ssm_access = true
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  
  # Network configuration
  public_subnet_id  = module.vpc.first_public_subnet_id
  private_subnet_id = module.vpc.first_private_subnet_id
  
  # Security configuration
  bastion_security_group_id    = module.security.bastion_security_group_id
  monitoring_security_group_id = module.security.monitoring_security_group_id
  
  # IAM configuration
  instance_profile_name = module.iam.ec2_instance_profile_name
  
  # SSH access - use your existing public key
  public_key = file("~/.ssh/id_rsa.pub")  # or your key path
}
