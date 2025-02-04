provider "aws" {
    region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "diploma-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-2a"]
  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "stage"
  }
}
resource "aws_security_group" "diploma_security_group" {
  name   = "security_group"
  vpc_id = module.vpc.vpc_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 30000
    cidr_blocks = ["0.0.0.0/0"]
  }
      
 ingress {
    from_port = 8090
    protocol = "tcp"
    to_port = 8090
    cidr_blocks = ["0.0.0.0/0"]
  }
      
ingress {
    protocol    = "tcp"
    from_port   = 30001
    to_port     = 30001
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "diploma_instance"  {
  count = 3
  subnet_id = module.vpc.public_subnets
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  vpc_security_groups_ids = [aws_security_group.diploma_security_group.id]
  key_name = "diploma_key"
}
