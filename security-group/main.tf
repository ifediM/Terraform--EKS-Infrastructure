# create security group for the app server
resource "aws_security_group" "app_server_security_group" {
  name        = "${var.project_name}-${var.environment}-app-server-sg"
  description = "enable ssh/https access on port 22/443 via alb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "ssh"
    cidr_blocks     = ["${var.vpc_cidr}"]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-server-sg"
  }
}