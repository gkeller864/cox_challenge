/*==========================
      AWS ECS Service
===========================*/

resource "aws_ecs_service" "ecs_service" {
  name                              = "service-${var.name}"
  cluster                           = var.ecs_cluster_id
  task_definition                   = var.arn_task_definition
  desired_count                     = var.desired_tasks
  health_check_grace_period_seconds = 60
  launch_type                       = "FARGATE"

  network_configuration {
    security_groups = var.arn_security_group
    subnets         = var.subnet_id
  }

  load_balancer {
    target_group_arn = var.arn_target_group
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }
}