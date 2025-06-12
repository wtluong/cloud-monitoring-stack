# Required Variables (must be provided when using module)
variable "name_prefix" {
  description = "Prefix for all resource names (same as VPC module)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the bastion host (e.g., ['YOUR_IP/32'])"
  type        = list(string)
}

# Optional Variables (have defaults, so they're optional)
variable "common_tags" {
  description = "Common tags to apply to all resources (same as VPC module)"
  type        = map(string)
  default     = {}
}
