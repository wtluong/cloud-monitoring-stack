# =============================================================================
# COMPUTE MODULE VARIABLES
# =============================================================================

variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network Variables
variable "public_subnet_id" {
  description = "Public subnet ID for bastion host"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for monitoring instance"
  type        = string
}

# Security Variables
variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "monitoring_security_group_id" {
  description = "Security group ID for monitoring instance"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for monitoring instance"
  type        = string
}

# SSH Key Variables
variable "public_key" {
  description = "Public key content for SSH access (e.g., contents of ~/.ssh/id_rsa.pub)"
  type        = string
}

# Instance Types
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "monitoring_instance_type" {
  description = "Instance type for monitoring instance"
  type        = string
  default     = "t3.medium"
}
