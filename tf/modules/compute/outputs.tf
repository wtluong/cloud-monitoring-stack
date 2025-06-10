# =============================================================================
# COMPUTE MODULE OUTPUTS
# =============================================================================

# Key Pair Outputs
output "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  value       = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "ID of the EC2 Key Pair"
  value       = aws_key_pair.main.id
}

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = aws_instance.bastion.public_dns
}

# Monitoring Instance Outputs
output "monitoring_instance_id" {
  description = "ID of the monitoring instance"
  value       = aws_instance.monitoring.id
}

output "monitoring_private_ip" {
  description = "Private IP of the monitoring instance"
  value       = aws_instance.monitoring.private_ip
}

output "monitoring_private_dns" {
  description = "Private DNS name of the monitoring instance"
  value       = aws_instance.monitoring.private_dns
}

output "monitoring_availability_zone" {
  description = "Availability zone of the monitoring instance"
  value       = aws_instance.monitoring.availability_zone
}

# Connection Information
output "ssh_bastion_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh ec2-user@${aws_instance.bastion.public_ip}"
}

output "ssh_monitoring_command" {
  description = "SSH command to connect to monitoring instance via bastion"
  value       = "ssh -o ProxyJump=ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.monitoring.private_ip}"
}

# Instance Summary
output "compute_summary" {
  description = "Summary of compute resources"
  value = {
    bastion = {
      id         = aws_instance.bastion.id
      public_ip  = aws_instance.bastion.public_ip
      private_ip = aws_instance.bastion.private_ip
      type       = aws_instance.bastion.instance_type
    }
    monitoring = {
      id         = aws_instance.monitoring.id
      private_ip = aws_instance.monitoring.private_ip
      type       = aws_instance.monitoring.instance_type
      az         = aws_instance.monitoring.availability_zone
    }
  }
}
