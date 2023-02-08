/*====================================
      AWS ECS Task definition
=====================================*/

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "task-definition-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = <<DEFINITION
    [
      
        "image": "${var.docker_repo}",
        "name": "${var.container_name}",
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ]
      },
        {
        "logConfiguration": {
            "logDriver": "awslogs",
            "secretOptions": null,
            "options": {
              "awslogs-group": "/ecs/task-definition-${var.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          }
    ]
  DEFINITION
}

# ------- CloudWatch Logs groups to store ecs-containers logs -------
resource "aws_cloudwatch_log_group" "TaskDF-Log_Group" {
  name              = "/ecs/task-definition-${var.environment_name}-${var.container_log}"
  retention_in_days = 1
}
