# 1. IP Elástica (EIP) para el NAT Gateway
resource "aws_eip" "aws_eip_nat_gateway" {
  domain = "vpc"
}

resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id     = aws_eip.aws_eip_nat_gateway.id
  
  
  subnet_id         = var.public_subnet_ids[0]
  connectivity_type = var.connectivity_type

  tags = merge({ "ResourceName" = "${var.name}-natgw" }, var.tags)
}


resource "aws_route_table" "aws_route_table_private" {
 
  vpc_id = var.vpc_id

  tags = merge({ "Name" = "${var.name}-private-rt" }, var.tags)
}

resource "aws_route" "private_routes" {
  route_table_id         = aws_route_table.aws_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway.id
}

resource "aws_route_table_association" "assoc_private_routes" {
  count          = length(var.private_subnet_ids)
  
  
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.aws_route_table_private.id
}


resource "aws_route_table" "aws_route_table_intranet" {
  
  vpc_id = var.vpc_id

  tags = merge({ "Name" = "${var.name}-intranet-rt" }, var.tags)
}



resource "aws_route_table_association" "assoc_intranet_routes" {
  count          = length(var.intranet_subnet_ids)
  
  # 🔄 CORREGIDO: Se asocian los IDs reales de las subredes de intranet
  subnet_id      = var.intranet_subnet_ids[count.index]
  route_table_id = aws_route_table.aws_route_table_intranet.id
}