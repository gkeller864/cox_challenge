variable "aws_profile" {
  description = "The profile name that you have configured in the file .aws/credentials"
  type        = string
}

variable "aws_region" {
  description = "The AWS Region in which you want to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "The name of your environment"
  type        = string
  default     = "sandbox-1"

  validation {
    condition     = length(var.environment_name) < 23
    error_message = "Due the this variable is used for concatenation of names of other resources, the value must have less than 23 characters."
  }
}

variable "vpc_id" {
  description = "The port used by your backend application"
  type        = number
  default     = 123
}

variable "private_subnet_id" {
  description = "The private subnet ID"
  type        = number
  default     = 123
}

variable "public_subnet_id" {
  description = "The public subnet ID"
  type        = number
  default     = 123
}

variable "port_app" {
  description = "The port used by your backend application"
  type        = number
  default     = 80
}

variable "container_name" {
  description = "The name of the container of each ECS service"
  type        = map(string)
  default = {
    nginx                 = "container-nginx"
  }
}

variable "iam_role_name" {
  description = "The name of the IAM Role for each service"
  type        = map(string)
  default = {
    devops        = "devOps-role"
    ecs           = "ECS-task-execution-role"
    ecs_task_role = "ECS-task-role"
    codedeploy    = "codedeploy-role"
    ecs_execution = "ECS-task-execution-role2"
  }
}
