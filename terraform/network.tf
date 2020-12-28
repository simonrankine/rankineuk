resource "aws_vpc" "rankineuk" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name    = "rankineuk",
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
  route_table_id         = aws_vpc.rankineuk.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
