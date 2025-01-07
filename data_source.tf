data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  default = true
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}