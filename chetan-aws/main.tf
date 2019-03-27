provider "aws" {

  region = "ap-southeast-2"
 }

resource "aws_instance" "server" {
  ami           = "ami-04481c741a0311bbb"
  instance_type = "t2.micro"

  tags {
    Name = "terraform-example"
  }
}