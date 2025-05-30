module "vpc" {
  source = "../../modules/vpc"
  
  name_prefix = "dev-monitoring"
  
  # NAT Gateway Configuration
  # enable_nat_gateway = true  # Uncomment to enable (~$33/month)
  
  # Current: Using module default (false) to save costs
  # When to enable:
  # - Private instances need internet
}
