# =============================================================================
# COMPUTE MODULE
# =============================================================================

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create SSH key pair from public key
resource "aws_key_pair" "main" {
  key_name   = "${var.name_prefix}-keypair"
  public_key = var.public_key

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-keypair"
  })
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type              = var.bastion_instance_type
  subnet_id                  = var.public_subnet_id
  vpc_security_group_ids     = [var.bastion_security_group_id]
  key_name                   = aws_key_pair.main.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-bastion"
      Type = "bastion"
    }
  )

  user_data = file("${path.module}/user-data/bastion.sh")
}

# Monitoring Instance
resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.monitoring_instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.monitoring_security_group_id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  # Additional volume for monitoring data
  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_type           = "gp3"
    volume_size           = 100
    encrypted             = true
    delete_on_termination = false

    tags = merge(
      var.common_tags,
      {
        Name = "${var.name_prefix}-monitoring-data"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-monitoring"
      Type = "monitoring"
    }
  )

  user_data = file("${path.module}/user-data/monitoring.sh")
}
