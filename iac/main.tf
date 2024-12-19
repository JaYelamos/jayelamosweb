provider "aws" {
  region = "eu-west-1"
}

module "ubuntu2204test" {
    count = 1
    source = "./modules/ec2instance"
    tagName = var.tagName
    ec2instanceName = "testec2"
}