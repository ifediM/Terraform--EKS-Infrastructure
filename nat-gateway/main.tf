# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 
resource "aws_eip" "eip1" {

  tags = {
    Name = "${var.project_name}-${var.environment}-eip1"
  }
}


# create nat gateway in public subnet az1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = var.public_subnet_az1_id

  tags = {
    Name = "${var.project_name}-${var.environment}-ng-az1"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc
  depends_on = [var.internet_gateway]
}

# create private route table and add route through nat gateway az1
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# associate private app subnet az1 with private route table
resource "aws_route_table_association" "private_app_subnet_az1_rt_az1_association" {
  subnet_id      = var.private_app_subnet_az1_id
  route_table_id = aws_route_table.private_route_table.id
}

# associate private app subnet az2 with private route table
resource "aws_route_table_association" "private_app_subnet_az2_rt_az2_association" {
  subnet_id      = var.private_app_subnet_az2_id
  route_table_id = aws_route_table.private_route_table.id
}