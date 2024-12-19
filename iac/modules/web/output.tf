output "moduleInstanceId" {
    value = aws_instance.ec2instance[*].id
}