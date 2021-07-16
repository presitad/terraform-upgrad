variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}


variable "az_list" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]

}

variable "ami" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "selfip" {
  type = string
  description = "Enter your public ip in format a.b.c.d/32"
}