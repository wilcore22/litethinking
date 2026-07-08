resource "aws_route_table" "aws_route_table_public" {
  vpc_id = var.vpc_id # ✅ Esto está perfecto.
}

resource "aws_route" "aws_route_public" {
  route_table_id         = aws_route_table.aws_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  

  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "aws_route_table_association_public" {
 
  count          = length(var.subnet_ids)
  
  
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.aws_route_table_public.id
}