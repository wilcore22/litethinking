output "aws_vpc_id" {
  value       = one(aws_vpc.aws_vpc_company[*].id)
  description = "id vpc"
}

output "vpc_id" {
  value = aws_vpc.aws_vpc_company[0].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.aws_internet_gateway_company[0].id
}