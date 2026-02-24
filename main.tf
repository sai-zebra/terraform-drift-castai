resource "aws_instance" "example" {
  ami                    = var.ami
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = var.instance_type
  # vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_web.id]
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]

  tags = {
    Name          = "terraform-drift"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.ssh_private_key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/home/ec2-user/script.sh"
  }
}
