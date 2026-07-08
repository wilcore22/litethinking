variable "connectivity_type" {
  description = "connectivity_type"
  type        = string
  default     = "public" # "private"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = []
}

variable "name_vpc" {}

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

variable "tags" {
  description = "Tag map for the resource"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}
