output "instanceId" {
    value = aws_instance.ubuntu2204.id
}

output "moduleInstanceId" { 
    value = module.ubuntu2204test[*].moduleInstanceId
}