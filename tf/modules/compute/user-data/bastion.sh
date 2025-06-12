#!/bin/bash
# Update system
yum update -y

# Install useful tools
yum install -y htop tmux git

# Set hostname
hostnamectl set-hostname bastion-host
