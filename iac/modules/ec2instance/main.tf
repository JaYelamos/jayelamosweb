resource "aws_instance" "ec2instance" {
    ami="ami-006cfe9f763a1cb77"
    instance_type = "t2.micro"
    tags = {
        Name = var.tagName
    }
}