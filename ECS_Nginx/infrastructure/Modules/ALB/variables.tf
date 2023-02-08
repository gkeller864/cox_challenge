variable "name" {
  description = "A name for the target group or ALB"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment this app will live in for the Cname record"
  type        = string
  default     = "test"
}

variable "target_group" {
  description = "The ARN of the created target group"
  type        = string
  default     = ""
}

variable "target_group_green" {
  description = "The ANR of the created target group"
  type        = string
  default     = ""
}

variable "create_alb" {
  description = "Set to true to create an ALB"
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Set to true to create a HTTPS listener"
  type        = bool
  default     = false
}

variable "enable_http" {
  description = "Set to true to create a HTTP listener"
  type        = bool
  default     = false
}

variable "create_target_group" {
  description = "Set to true to create a Target Group"
  type        = bool
  default     = false
}

variable "subnet" {
  description = "Subnets IDs for ALB"
  type        = list(any)
  default     = []
}

variable "security_group" {
  description = "Security group ID for the ALB"
  type        = list(any)
  default     = []
}

variable "port" {
  description = "The port that the target group will use"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "The protocol that the target group will use"
  type        = string
  default     = ""
}

variable "vpc" {
  description = "VPC ID for the Target Group"
  type        = string
  default     = ""
}

variable "tg_type" {
  description = "Target Group Type (instance, IP, lambda)"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "The path in which the ALB will send health checks"
  type        = string
  default     = ""
}

variable "health_check_port" {
  description = "The port to which the ALB will send health checks"
  type        = any
  default     = "traffic-port"
}

variable "nginx_acm_certificate" {
  description = "The arn of the ACM cert created for this ALB for the nginx listener"
  type        = string
  default     = ""
}
