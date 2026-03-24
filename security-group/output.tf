# export the app server security group id
output "app_server_security_group_id" {
  value = aws_security_group.app_server_security_group.id
}