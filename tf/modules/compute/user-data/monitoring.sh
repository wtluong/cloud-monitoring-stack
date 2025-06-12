#!/bin/bash
# Update system
yum update -y

# Install dependencies
yum install -y wget curl

# Set hostname  
hostnamectl set-hostname monitoring-host
