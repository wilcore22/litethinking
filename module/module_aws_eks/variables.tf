variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "name_cluster" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = []
}

variable "intranet_subnet_cidrs" {
 type        = list(string)
 description = "Intranet Subnet CIDR values"
 default     = []
}