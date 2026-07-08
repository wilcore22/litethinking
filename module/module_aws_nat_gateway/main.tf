resource "aws_eip" "aws_eip_nat_gateway" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id     = aws_eip.aws_eip_nat_gateway.id
  subnet_id         = var.public_subnet_cidrs[0]
  connectivity_type = var.connectivity_type #"public" #"private"

  tags = merge({ "ResourceName" = "${var.name}-natgw" }, var.tags)

}


resource "aws_route_table" "aws_route_table_private" {
  vpc_id = var.name_vpc

}

resource "aws_route" "private_routes" {
  route_table_id         = aws_route_table.aws_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway.id
}

resource "aws_route_table_association" "assoc_private_routes" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(var.private_subnet_cidrs, count.index)
  route_table_id = aws_route_table.aws_route_table_private.id
}


resource "aws_route_table" "aws_route_table_intranet" {
  vpc_id = var.name_vpc

}

resource "aws_route" "intranet_routes" {
  route_table_id         = aws_route_table.aws_route_table_intranet.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway.id
}

resource "aws_route_table_association" "intranet_routes" {
  count = length(var.intranet_subnet_cidrs)
  subnet_id      = element(var.intranet_subnet_cidrs, count.index)
  route_table_id = aws_route_table.aws_route_table_intranet.id
}