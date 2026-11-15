terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Creating the EC2 instance:

resource "aws_instance" "Wordpress_instance" {
  ami = var.instance_ubuntu_ami
  instance_type = var.instance_type
  key_name = "wordpress-key"
  vpc_security_group_ids = [aws_security_group.WordPress_sg.id]

#user data script:
user_data = file("${path.module}/user_data.sh")

#Wordpress_instance_key

tags = {
    Name = "WordPress-Server"
    }

}

#Creating the WordPress-server-key:

# 1. Generate the key locally
resource "tls_private_key" "wordpress_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register the public key with AWS
resource "aws_key_pair" "wordpress_key" {
  key_name   = "wordpress-key"
  public_key = tls_private_key.wordpress_key.public_key_openssh
}

# 3. Save the private key to my computer
resource "local_file" "private_key" {
  content         = tls_private_key.wordpress_key.private_key_pem
  filename        = "${path.module}/wordpress-key.pem"
  file_permission = "0600"
}

#Creating ec2 wordpress sg:

resource "aws_security_group" "WordPress_sg" {
  name = "WordPress_sg"
  description = "Allows web from anywhere and ssh from my IP only"

  #Inbound rules:
  #http traffic
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ssh traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = ["92.41.53.229/32"] #myip
    cidr_blocks = ["0.0.0.0/0"] #testing only
  }

  #Outbound rules:
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. Create an Internet Gateway for the Default VPC
resource "aws_internet_gateway" "default_igw" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "default-vpc-igw"
  }
}

# 2. Fix the Default Route Table so it points to the new IGW
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = data.aws_vpc.default.main_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_igw.id
  }

  tags = {
    Name = "default-public-route-table"
  }
}

data "aws_vpc" "default" {
  default = true
}