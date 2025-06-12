# Required Variables
variable "name_prefix" {
  description = "Prefix for all resource names (e.g., 'dev-monitoring', 'prod-monitoring')"
  type        = string
}

# Optional Variables
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs permissions for EC2 instances"
  type        = bool
  default     = true
}

variable "enable_ssm_access" {
  description = "Enable Systems Manager Session Manager access (alternative to SSH)"
  type        = bool
  default     = false  # Can enable later if you want to try SSM
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
