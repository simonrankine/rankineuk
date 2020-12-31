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

output "rankineuk_name_servers" {
  value = aws_route53_zone.primary.name_servers
}

output "ec2_instance_ip" {
  value = aws_instance.rankineuk_server.public_ip
}
