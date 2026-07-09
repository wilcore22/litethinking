variable "name" {
  type    = string
  default = "litethinking"
}

variable "vpc_id" {
  type        = string
  description = "ID real de la VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs reales de subredes públicas (donde se aloja el NAT)"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs reales de subredes privadas"
}

variable "intranet_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Lista de IDs reales de subredes aisladas (ej. bases de datos)"
}

variable "connectivity_type" {
  type    = string
  default = "public"
}

variable "tags" {
  type    = map(string)
  default = {}
}