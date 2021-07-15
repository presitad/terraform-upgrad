variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}


variable "az_list" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]

}
