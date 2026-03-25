# Security groups variable
variable "project_name" {}
variable "environment" {}
variable "vpc_id" {}
variable "ssh_ip" {
  description = "IP address allowed to access the app server via ssh"
}