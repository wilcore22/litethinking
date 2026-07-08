variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = []
}


variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = []
}


variable "vpc_id" {
  type = string
}