provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project   = "cloud-monitoring"
      ManagedBy = "terraform"
    }
  }
}
