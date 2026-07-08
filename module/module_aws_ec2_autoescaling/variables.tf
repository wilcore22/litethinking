variable "name" {}

variable "tags" {
  description = "Tag map for the resource"
  type        = map(string)
  default     = {}
}




variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}

variable "security_group_ids" {
  description = "List of Security Group IDs to associate with the EC2 instance"
  type        = list(string)
}

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


# Auto Scaling
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "asg_health_check_type" {}
variable "target_group_arns" {}

variable "aws_lb" {
  description = "List of Security Group IDs to associate with the EC2 instance"
  type        = list(string)
}

