variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "ami_filter" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  type    = string
  default = "099720109477" # Canonical
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "deployment_bucket_name" {
  type    = string
  default = "rankineuk-deployment-bucket"
}
