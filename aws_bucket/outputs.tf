output "ec2_public_ip" {
    value = aws_instance.ngnix.public_ip
}