# Configure the AWS Provider to be added to variables
provider "aws" {
  region = "eu-west-2"
}

#EC2 variables:

variable "instance_ubuntu_ami" {
  type = string
  default = "ami-04d9aef197720113b"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}