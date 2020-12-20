variable "region" {
  default = "us-east-1"
}

variable "amis" {
  default = {
    "us-east-1" = "ami-04d29b6f966df1537"
    "us-west-2" = "ami-08d70e59c07c61a3a"
  }
}
