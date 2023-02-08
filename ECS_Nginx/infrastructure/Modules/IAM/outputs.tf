output "arn_role" {
  value = aws_iam_role.ecs_task_excecution_role.arn
}

output "name_role" {
  value = aws_iam_role.ecs_task_excecution_role.name
}

output "arn_role_ecs_task_role" {
  value = aws_iam_role.ecs_task_role.arn
}
