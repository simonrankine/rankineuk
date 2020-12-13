variable "aws_region" {
    type = string
    default = "eu-west-1"
}

variable "ami_filter" {
    type = string
    default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
    type = string
    default = "099720109477" # Canonical
}

variable "instance_type" {
    type = string
    default = "t2.nano"
}

provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "rankineuk" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "rankineuk",
    Project = "rankineuk"
  }
}

resource "aws_subnet" "rankineuk" {
  vpc_id     = aws_vpc.rankineuk.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "rankineuk"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.rankineuk.id

  tags = {
    Name = "rankineuk"
  }
}

resource "aws_route" "r" {
  route_table_id            = aws_vpc.rankineuk.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.rankineuk.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh",
    Project = "rankineuk"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner]
}

resource "aws_key_pair" "simon_key" {
  key_name = "simon_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDr1PzrNj002nY7B+puNw2S7wAKBKFDlbY4XnHsuon6y8eD2mVNswMFYhbLS01LCq1OnO28p62sGFjDek4nob+5TUbadXpcJ/086OrQ+LyRSHJhWZouS++53FP+g2tmzW0tWOqqFWrNZW/WfmhjnMXUAje12UMUh2P+resxPUcmxlpR2GWiIqWf6Gh+4VU/lhP8FsosIsv2VCvXqITMqWHyJ81Biu7wot/GgeY0rT6Zv/ZTB4DDZ7ZXZbOnbjF0YFJpOvIvpXEMr19FhBnes31UyoB/YVBbZxChRXASwblqgXVzAC5RPKLlWPsrzGQctCpQBNcLCQuT78K2Gy62fKuP1YKbusXrP7XOumeGzmB/pJGwhQD1NBYbsXn5Jqkg8p9IgMB7Qq6Ix/VK2L0s0YFNraZBKdY3WjUEJXg9f3+ABaaC5K8W0872+wp6HAr9IJKGekyb8RgnNjl4LilmgMCRRUcukh9RBPxpAnVa+5Qyq2nIXi2+rkQhtM9pENOZHt0="
}

resource "aws_instance" "rankineuk_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  associate_public_ip_address = true
  key_name = aws_key_pair.simon_key.key_name
  subnet_id = aws_subnet.rankineuk.id

  tags = {
    Name = "rankineuk"
    Project = "rankineuk"
  }
}

output "ec2_instance_ip" {
    value = aws_instance.rankineuk_server.public_ip
}
