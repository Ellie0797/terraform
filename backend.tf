terraform {
  backend "s3" {
    bucket  = "ellie-terraform-backend"
    key     = "ellie-terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}