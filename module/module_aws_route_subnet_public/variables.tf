variable "vpc_id" {
  type        = string
  description = "ID real de la VPC"
}

variable "internet_gateway_id" {
  type        = string
  description = "ID real del Internet Gateway"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de los IDs reales de las subredes creadas"
}