variable "intranet_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs reales de las subredes de intranet para RDS"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group para acceso a MySQL (puerto 3306)"
}