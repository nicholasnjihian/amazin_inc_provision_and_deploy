provider "aws" {
   profile = "default"
   region  = "us-east-1"
}
resource "aws_instance" "base" {
   ami           = ""
   instance_type = "t2.micro"
}

