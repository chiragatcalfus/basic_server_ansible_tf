variable "vpc_ip" {
  description = "vpc ip configuration"
  default = "10.0.0.0/16"
  type = string
}

variable "instance_ami" {
  description = "aws ami for instance"
  type = string
}

variable "instance_type" {
  type = string
}
