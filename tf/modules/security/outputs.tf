# Output the bastion security group ID (needed for EC2 instances)
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

# Output the monitoring security group ID
output "monitoring_security_group_id" {
  description = "ID of the monitoring security group"
  value       = aws_security_group.monitoring.id
}
