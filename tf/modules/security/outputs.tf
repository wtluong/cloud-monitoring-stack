# Output the bastion security group ID (needed for EC2 instances)
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}
