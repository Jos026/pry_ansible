resource "aws_security_group" "nginx" {
  name   = var.sg_name
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ngnix" {
  ami             = local.ami_id
  instance_type   = var.ec2_ami
  security_groups = [aws_security_group.nginx.name]
  key_name        = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.ngnix.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.ngnix.public_ip}, --private-key ${local.private_key_path} nginx.yml"
  }

  tags = {
    "name" = "proyecto"
  }
}