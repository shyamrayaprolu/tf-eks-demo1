terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region  = "<aws-region>-1"
  profile = "default"
  version = ">= 2.66.0"
}

provider "random" {
  version = "~> 2.2.1"
}