# Outputs from the VPC module
# These values can be used by other modules or the root configuration

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

# Subnet Information
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# Specific subnet outputs (useful for placing resources)
output "first_public_subnet_id" {
  description = "ID of the first public subnet (useful for bastion host)"
  value       = length(aws_subnet.public) > 0 ? aws_subnet.public[0].id : null
}

output "first_private_subnet_id" {
  description = "ID of the first private subnet (useful for internal resources)"
  value       = length(aws_subnet.private) > 0 ? aws_subnet.private[0].id : null
}

# Gateway Information
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}

# Route Table Information
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table (if NAT enabled)"
  value       = var.enable_nat_gateway ? aws_route_table.private[0].id : null
}

# Availability Zones Used
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# Summary Information
output "vpc_summary" {
  description = "Summary of the VPC configuration"
  value = {
    vpc_id               = aws_vpc.this.id
    vpc_cidr            = aws_vpc.this.cidr_block
    public_subnet_count = length(aws_subnet.public)
    private_subnet_count = length(aws_subnet.private)
    nat_gateway_enabled = var.enable_nat_gateway
    region              = data.aws_region.current.name
  }
}

# Data source to get current region
data "aws_region" "current" {}
