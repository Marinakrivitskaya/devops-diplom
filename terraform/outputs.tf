output "private_ip" {
 value = aws_instance.diploma_instance.*.private_ip
}

output "public_ip" {
 value = aws_instance.diploma_instance.*.public_ip
}
