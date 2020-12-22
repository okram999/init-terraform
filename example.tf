terraform {
  backend "s3" {
    # bucket = "nokram-tf-state"
    # encrypt = true
    # key = "terraform.tfstate"
    # region = "us-east-1"
    # dynamodb_table = "terraform-state-lock-dynamo" 
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "example" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}



output "ip" {
  value = aws_eip.ip.public_ip
}

