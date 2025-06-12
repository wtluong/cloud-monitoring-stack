# IAM Role Outputs
output "ec2_role_name" {
  description = "Name of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.name
}

output "ec2_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}

# Instance Profile Output (This is what EC2 actually uses)
output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

# Summary Output
output "iam_summary" {
  description = "Summary of IAM resources created"
  value = {
    role_name              = aws_iam_role.ec2_role.name
    instance_profile_name  = aws_iam_instance_profile.ec2_profile.name
    cloudwatch_enabled     = var.enable_cloudwatch_logs
    ssm_enabled           = var.enable_ssm_access
  }
}
