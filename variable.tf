# variable to specify the Name tag value for the first EC2 instance
variable "instance1_name" { 
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "web_server1"
}

# variable to specify the Name tag value for the second EC2 instance
variable "instance2_name" { 
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "web_server2"
}
