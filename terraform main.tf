provider "aws" {
  region     = var.region
  access_key = var.key
  secret_key = var.sec-key
}

resource "aws_security_group" "my-sg1" {
  
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"

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
    Name = "allow_tls"
  }
}

data "aws_vpc" "existing" {
  default = true
}

data "aws_subnet" "selected" {

  vpc_id = data.aws_vpc.existing.id
  filter {
    name  = "tag:name"
    values = ["defaultsubnet"]
  }

}


resource "aws_instance" "my-instance" {
  key_name                    = "webserver-key"
  instance_type               = "t2.micro"
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.my-sg1.id]
  availability_zone           = "ap-south-1a"
  ami                         = "ami-0851b76e8b1bce90b"
  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  tags = {
    name = "my-instance"
  }

}