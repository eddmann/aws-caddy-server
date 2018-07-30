data "http" "ip" {
  url = "http://icanhazip.com"
}

resource "aws_vpc" "caddy" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name      = "Caddy-VPC"
    Terraform = "Yes"
  }
}

resource "aws_subnet" "caddy" {
  vpc_id                  = "${aws_vpc.caddy.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.caddy_availability_zone}"
  map_public_ip_on_launch = false

  tags {
    Name      = "Caddy-Subnet"
    Terraform = "Yes"
  }
}

resource "aws_security_group" "caddy" {
  name        = "Caddy-Security-Group"
  description = "Security Group for Caddy"
  vpc_id      = "${aws_vpc.caddy.id}"

  tags {
    Name      = "Caddy-Security-Group"
    Terraform = "Yes"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ip.body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_internet_gateway" "caddy" {
  vpc_id = "${aws_vpc.caddy.id}"

  tags {
    Name      = "Caddy-Internet-Gateway"
    Terraform = "Yes"
  }
}

resource "aws_route" "caddy" {
  route_table_id         = "${aws_vpc.caddy.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.caddy.id}"
}
