resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/key.pub")
}

resource "aws_instance" "example" {
  ami                    = var.ami
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = var.instance_type
  # vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_web.id]
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  user_data              = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              sed -i -e 's/80/8080/' /etc/httpd/conf/httpd.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart httpd
              systemctl enable httpd
              EOF
  tags = {
    Name          = "terraform-learn-state-ec2"
    drift_example = "v1"
  }
}

resource "aws_security_group" "sg_ssh" {
  name = "sg_ssh"
  ingress {
    from_port   = "22"
    to_port     = "22"
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

# resource "aws_security_group" "sg_web" {
#   name        = "sg_web"
#   description = "allow 8080"
# }

# resource "aws_security_group_rule" "sg_web" {
#   type      = "ingress"
#   to_port   = "8080"
#   from_port = "8080"
#   protocol  = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sg_web.id
# }
