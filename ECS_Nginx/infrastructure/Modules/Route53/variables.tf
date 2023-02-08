variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "route_53_name" {
  description = "The name of the record"
  type        = string
  default     = "test"
}

variable "record" {
  description = "The name of ALB record"
  type        = string
}
