provider "aws" {
  region = "eu-west-1"
}

module "web" {
    source = "./modules/web"
    accesstoken = var.accesstoken
}