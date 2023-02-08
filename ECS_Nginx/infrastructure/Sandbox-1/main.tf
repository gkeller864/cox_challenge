/*===========================
          Root file
============================*/
# ------- Providers -------
provider "aws" {
  ## profile = var.aws_profile
  region  = var.aws_region

  # provider level tagging
   default_tags {
     tags = {
       Created_by = "Terraform"
       Project    = "AWS_${var.environment_name}_devops"
     }
   }
}

# VPC Data sources
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Private Subnet Data sources 
data "aws_subnet" "selected_private" {
  id = var.private_subnet_id
}

# Public Subnet Data sources 
data "aws_subnet" "selected_public" {
  id = var.public_subnet_id
}

# ------- Random numbers intended to be used as unique identifiers for resources -------
resource "random_id" "RANDOM_ID" {
  byte_length = "2"
}

# ------- Account ID -------
data "aws_caller_identity" "id_current_account" {}

# ------- Creating Route53 Zones and Records -------
module "route53_nginx" {
  source           = "../Modules/Route53"
  environment_name = "${var.environment_name}"
  route_53_name    = "${var.environment_name}"
  record           = module.alb_nginx.dns_alb
}

# ------- Creating ALB -------
module "alb_nginx" {
  source                = "../Modules/ALB"
  create_alb            = true
  name                  = "${var.environment_name}-nginx"
  subnet                = local.public_subnet
  security_group        = [module.security_group_alb_https.sg_id,module.security_group_alb_http.sg_id]
  target_group          = module.target_group_nginx.arn_tg
  nginx_acm_certificate = module.route53_nginx.aws_acm_certificate
}

# ------- Creating Target Group for the nginx ALB -------
module "target_group_nginx" {
  source              = "../Modules/ALB"
  create_target_group = true
  name                = "tg-${var.environment_name}-s-b-nginx"
  port                = var.port_app
  protocol            = "HTTP"
  vpc                 = local.vpc_id
  tg_type             = "ip"
  health_check_path   = "/up"
  health_check_port   = var.port_app
}

# ------- Creating Security Group for the server ALB -------
module "security_group_alb_http" {
  source              = "../Modules/SecurityGroup"
  name                = "alb-${var.environment_name}-http"
  description         = "Controls access to the ALBs"
  vpc_id              = local.vpc_id
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 80
}

module "security_group_alb_https" {
  source              = "../Modules/SecurityGroup"
  name                = "alb-${var.environment_name}-https"
  description         = "Controls access to the ALBs"
  vpc_id              = local.vpc_id
  cidr_blocks_ingress = ["0.0.0.0/0"]
  ingress_port        = 443
}

# ------- ECS Role -------
module "ecs_role" {
  source             = "../Modules/IAM"
  name               = var.iam_role_name["ecs"]
  name_ecs_task_role = var.iam_role_name["ecs_task_role"]
}

# ------- Creating a IAM Policy for role -------›
module "ecs_role_policy" {
  source        = "../Modules/IAM"
  name          = "ecs-ecr-${var.environment_name}"
  create_policy = true
  attach_to     = module.ecs_role.name_role
}

# ------- Creating ECS Task Definition for the server -------
module "ecs_task_definition_nginx" {
  source             = "../Modules/ECS/TaskDefinition"
  docker_repo        = "nginx:latest"
  name               = "${var.environment_name}-nginx"
  environment_name   = "${var.environment_name}"
  container_name     = "nginx"
  execution_role_arn = module.ecs_role.arn_role
  task_role_arn      = module.ecs_role.arn_role_ecs_task_role
  cpu                = 256
  memory             = "512"
  region             = var.aws_region
  container_log      = "nginx"
}

# ------- Creating a server Security Group for ECS TASKS -------
module "security_group_ecs_task_nginx" {
  source          = "../Modules/SecurityGroup"
  name            = "ecs-task-${var.environment_name}-tasks-nginx"
  description     = "Controls access to the server ECS task"
  vpc_id          = local.vpc_id
  ingress_port    = var.port_app
  security_groups = [module.security_group_alb_http.sg_id,module.security_group_alb_https.sg_id]
}


# ------- Creating ECS Clusters -------
module "ecs_cluster" {
  source = "../Modules/ECS/Cluster"
  name   = "${var.environment_name}-example"
}

# ------- Creating ECS Services -------
module "ecs_service_nginx" {
  depends_on          = [module.alb_nginx]
  source              = "../Modules/ECS/Service"
  name                = "${var.environment_name}-nginx"
  desired_tasks       = 1
  arn_security_group  = [module.security_group_ecs_task_nginx.sg_id]
  ecs_cluster_id      = module.ecs_cluster.ecs_cluster_id
  arn_target_group    = module.target_group_nginx.arn_tg
  arn_task_definition = module.ecs_task_definition_nginx.arn_task_definition
  subnet_id           = local.private_subnet
  container_port      = var.port_app
  container_name      = "nginx"
}

# ------- Creating ECS Autoscaling policies for the applications -------
module "ecs_autoscaling_nginx" {
  source       = "../Modules/ECS/Autoscaling"
  name         = "${var.environment_name}-nginx"
  cluster_name = module.ecs_cluster.ecs_cluster_name
  min_capacity = 1
  max_capacity = 1

  depends_on   = [module.ecs_service_nginx]
}
