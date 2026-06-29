variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "wiz-demo"
}
variable "ssh_public_key" {
  description = "SSH public key for MongoDB VM"
  type        = string
}