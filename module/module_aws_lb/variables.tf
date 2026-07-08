variable "name_lb" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}

variable "security_group_ids" {
  type = list(string)
}

# 🔄 Nueva variable de IDs de subred
variable "subnet_ids" {
  type        = list(string)
  description = "Lista de los IDs reales de las subredes públicas"
}

variable "vpc_id" {
  type = string
}

variable "lb_target_port" {
  type    = number
  default = 80
}

variable "lb_protocol" {
  type    = string
  default = "HTTP"
}

variable "lb_target_type" {
  type    = string
  default = "instance"
}

variable "lb_listener_port" {
  type    = number
  default = 80
}

variable "lb_listener_protocol" {
  type    = string
  default = "HTTP"
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

# 🔄 Nueva variable para asociar la instancia EC2
variable "target_instance_ids" {
  type        = list(string)
  description = "Lista de IDs de las instancias EC2 a conectar al Target Group"
  default     = []
}