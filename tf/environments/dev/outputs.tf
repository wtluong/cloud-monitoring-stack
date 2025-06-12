# =============================================================================
# DEVELOPMENT ENVIRONMENT OUTPUTS
# =============================================================================

# Environment Information
output "environment" {
  description = "The deployment environment"
  value       = local.environment
}

output "name_prefix" {
  description = "The common name prefix used for resources"
  value       = local.name_prefix
}

output "my_public_ip" {
  description = "Your detected public IP address"
  value       = local.my_ip_cidr
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Security Group Outputs
output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = module.security.bastion_security_group_id
}

output "monitoring_security_group_id" {
  description = "ID of the monitoring security group"
  value       = module.security.monitoring_security_group_id
}

# IAM Outputs
output "iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = module.iam.ec2_role_name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}

# Compute Outputs
output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.compute.bastion_public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of bastion host"
  value       = module.compute.bastion_public_dns
}

output "monitoring_private_ip" {
  description = "Private IP of monitoring instance"
  value       = module.compute.monitoring_private_ip
}

output "monitoring_private_dns" {
  description = "Private DNS of monitoring instance"
  value       = module.compute.monitoring_private_dns
}

# SSH Connection Commands
output "ssh_commands" {
  description = "SSH connection commands"
  value = {
    bastion    = module.compute.ssh_bastion_command
    monitoring = module.compute.ssh_monitoring_command
  }
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    environment = local.environment
    vpc_id      = module.vpc.vpc_id
    
    bastion = {
      public_ip  = module.compute.bastion_public_ip
      public_dns = module.compute.bastion_public_dns
    }
    
    monitoring = {
      private_ip  = module.compute.monitoring_private_ip
      private_dns = module.compute.monitoring_private_dns
    }
    
    ssh_access = {
      bastion_command    = module.compute.ssh_bastion_command
      monitoring_command = module.compute.ssh_monitoring_command
    }
  }
}
