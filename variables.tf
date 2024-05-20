variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for main"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones_1" {
  type    = string
  default = "us-west-2a"
}

variable "availability_zones_2" {
  type    = string
  default = "us-west-2b"
}