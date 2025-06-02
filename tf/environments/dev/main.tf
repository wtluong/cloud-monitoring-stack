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
}

# Security Module
module "security" {
  source = "../../modules/security"
  
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [local.my_ip_cidr]
  common_tags       = local.common_tags
}
