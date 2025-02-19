resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "vpc-${var.env}"
    Env  = var.env
  }
}