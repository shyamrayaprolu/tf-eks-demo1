# Backend configuration is loaded early so we can't use variables
# Make sure to update the values mentioned in the anchor below
terraform {
  backend "s3" {
    region  = "<aws-region>"
    bucket  = "<aws-s3-bucket-name>"
    key     = "terraform/<environment>/terraform.tfstate"
    encrypt = true #AES-256 encryption
  }
}