# Input variables for the VPC module
# These allow you to customize the VPC for different environments

variable "name_prefix" {
  description = "Prefix for resource names (e.g., 'dev-monitoring', 'prod-monitoring')"
  type        = string
  
  # Validation: Ensure name follows conventions
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  # Validation: Ensure valid CIDR
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of AZs to use for subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # Validation: Ensure we have at least one public subnet
  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access (costs ~$45/month)"
  type        = bool
  default     = false  # Default to false to save money during learning
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Best Practice: Document your defaults
# - VPC CIDR: 10.0.0.0/16 provides 65,536 IP addresses
# - Public Subnets: 10.0.1.0/24 and 10.0.2.0/24 (512 IPs total)
# - Private Subnets: 10.0.10.0/24 and 10.0.20.0/24 (512 IPs total)
# - NAT Gateway: Disabled by default (enable for production)
