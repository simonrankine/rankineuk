terraform {
  backend "s3" {
    bucket = "rankineuk-tfstate"
    key    = "rankineuk/key"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}

output "ec2_instance_ip" {
  value = aws_instance.rankineuk_server.public_ip
}
