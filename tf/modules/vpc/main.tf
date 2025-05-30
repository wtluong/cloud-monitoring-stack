# VPC Module - This is a reusable component
# You can use this same module for dev, staging, and prod

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr  # Use variable for flexibility
  
  # Best practice: Always enable DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,  # Inherit common tags
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

# Internet Gateway - Allows internet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

# Elastic IP for NAT Gateway (if enabled)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0  # Only create if NAT is enabled
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-nat-eip"
    }
  )

  # Best practice: EIP depends on IGW
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (optional - costs money!)
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id  # Place in first public subnet

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-nat"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # Auto-assign public IPs

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
      Type = "private"
    }
  )
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-public-rt"
    }
  )
}

# Route to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-private-rt"
    }
  )
}

# Route to NAT Gateway (if enabled)
resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
