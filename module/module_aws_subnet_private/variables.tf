variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = []
}


variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = []
}

variable "name_vpc" {}