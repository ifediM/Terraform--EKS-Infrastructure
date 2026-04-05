# create security group for the app server
resource "aws_security_group" "app_server_security_group" {
  name        = "${var.project_name}-${var.environment}-app-server-sg"
  description = "enable ssh/https access on port 22/443 via alb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "https access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [aws_security_group.alb_sg.id]
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


resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "enable alb expose the app access via alb sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow everyone to hit the redirect
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow everyone to see the site
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eice_security_group" {
  name        = "${var.project_name}-${var.environment}-eice-sg"
  description = "Security group for EC2 Instance Connect Endpoint"
  vpc_id      = var.vpc_id

  # Ingress: Allow SSH traffic from the internet to the Endpoint
  ingress {
    description = "SSH from the internet to EICE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This is safe because EICE requires IAM auth
  }

  # Egress: Allow the Endpoint to send SSH traffic to your App Servers
  egress {
    description     = "Allow EICE to talk to App Servers"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_server_security_group.id]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eice-sg"
  }
}

# This standalone resource breaks the cycle
resource "aws_security_group_rule" "allow_eice_to_app" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_server_security_group.id
  source_security_group_id = aws_security_group.eice_security_group.id
  description              = "Allow SSH from EICE"
}