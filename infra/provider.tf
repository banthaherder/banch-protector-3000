# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

# Configure the GitHub Provider
provider "github" {
  organization = "banthacloud"
}

terraform {
  backend "s3" {
    bucket = "banthaherder.terraform"
    key    = "terraform/github-challenge"
    region = "us-west-2"
  }
}
