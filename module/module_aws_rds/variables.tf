variable "private_group_name" {
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "List of Security Group IDs to associate with the EC2 instance"
  type        = list(string)
  default     = []
}