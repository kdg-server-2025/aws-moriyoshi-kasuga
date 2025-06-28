# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# data "aws_ami" "ubuntu" {
#   most_recent = true
#
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
#
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#
#   owners = ["099720109477"] # Canonical
# }
#
# resource "aws_instance" "kdg-aws-20250621-user-date-enable" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#
#   tags = {
#     Name     = "kdg-aws-20250621-user-date-enable",
#     UserDate = "true"
#   }
#
#   security_groups             = [aws_security_group.ssh_enable.name]
#   user_data_replace_on_change = true
#
#   user_data = file("./ec2.sh")
# }
#
# variable "vpc_id" {
#   description = "The ID of the VPC where the EC2 instance will be launched"
#   type        = string
# }
#
# data "aws_vpc" "main" {
#   id = var.vpc_id
# }
#
# resource "aws_security_group" "ssh_enable" {
#   name        = "ssh-enable"
#   description = "Allow SSH access from anywhere"
#   vpc_id      = data.aws_vpc.main.id
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
