terraform {
  required_version = ">= 0.12"
}
provider "aws" {
  region                  = var.aws_region
  profile                 = var.profile
  shared_credentials_file = var.shared_credentials_file
}