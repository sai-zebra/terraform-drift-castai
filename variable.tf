variable "region" {
  description = "The AWS region your resources will be deployed"
  type = string
}

variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type = string
}
variable "instance_type" {
  description = "The type of EC2 instance to use"
  type = string
}
variable "key_name" {
  description =  "The name of the key pair to use for SSH access to the EC2 instance"
  type = string
}

variable "ssh_public_key" {
  description = "The public SSH key to use for the AWS key pair"
  type = string
}

variable "ssh_private_key" {
  description = "The private SSH key to use for connecting to the EC2 instance"
  type = string
}

