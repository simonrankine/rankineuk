resource "aws_iam_role" "rankineuk_ec2_iam_role" {
  name = "rankineuk_ec2_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },{
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "tls_certs" {
  role       = aws_iam_role.rankineuk_ec2_iam_role.name
  policy_arn = aws_iam_policy.tls_certs.arn
}

resource "aws_iam_instance_profile" "rankineuk_instance_profile" {
  name = "rankineuk_instance_profile"
  role = aws_iam_role.rankineuk_ec2_iam_role.id
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = "rankineuk_instance_profile"
  role = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
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
    Name    = "allow_ssh",
    Project = "rankineuk"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.rankineuk.id

  ingress {
    description = "HTTP from anywhere"
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

  tags = {
    Name    = "allow_http",
    Project = "rankineuk"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.rankineuk.id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
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
    Name    = "allow_http",
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
  key_name   = "simon_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDr1PzrNj002nY7B+puNw2S7wAKBKFDlbY4XnHsuon6y8eD2mVNswMFYhbLS01LCq1OnO28p62sGFjDek4nob+5TUbadXpcJ/086OrQ+LyRSHJhWZouS++53FP+g2tmzW0tWOqqFWrNZW/WfmhjnMXUAje12UMUh2P+resxPUcmxlpR2GWiIqWf6Gh+4VU/lhP8FsosIsv2VCvXqITMqWHyJ81Biu7wot/GgeY0rT6Zv/ZTB4DDZ7ZXZbOnbjF0YFJpOvIvpXEMr19FhBnes31UyoB/YVBbZxChRXASwblqgXVzAC5RPKLlWPsrzGQctCpQBNcLCQuT78K2Gy62fKuP1YKbusXrP7XOumeGzmB/pJGwhQD1NBYbsXn5Jqkg8p9IgMB7Qq6Ix/VK2L0s0YFNraZBKdY3WjUEJXg9f3+ABaaC5K8W0872+wp6HAr9IJKGekyb8RgnNjl4LilmgMCRRUcukh9RBPxpAnVa+5Qyq2nIXi2+rkQhtM9pENOZHt0="
}

resource "aws_instance" "rankineuk_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.rankineuk_instance_profile.id
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_https.id
  ]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.simon_key.key_name
  subnet_id                   = aws_subnet.rankineuk.id
  user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y wget ruby
cd /home/ubuntu
wget https://aws-codedeploy-${var.aws_region}.s3.${var.aws_region}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto > /tmp/logfile
sudo service codedeploy-agent start
  EOF

  tags = {
    Name    = "rankineuk"
    Project = "rankineuk"
  }

  lifecycle {
    create_before_destroy = true
  }

}
