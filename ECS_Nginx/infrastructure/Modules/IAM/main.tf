/*===========================================
      AWS IAM for different resources
============================================*/

# ------- IAM Roles -------
resource "aws_iam_role" "ecs_task_excecution_role" {
  name               = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.name_ecs_task_role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name = var.name_ecs_task_role
  }

  lifecycle {
    create_before_destroy = true
  }
}


# ------- IAM Policies -------
resource "aws_iam_policy" "policy_for_ecs_task_role" {
  name        = "Policy-${var.name_ecs_task_role}"
  description = "IAM Policy for Role ${var.name_ecs_task_role}"
  policy      = data.aws_iam_policy_document.role_policy_ecs_task_role.json

  lifecycle {
    create_before_destroy = true
  }
}  

resource "aws_iam_policy" "policy_for_ecs_task_execution_role" {
  name        = "Policy-ECS-${var.name_ecs_task_role}"
  description = "IAM Policy for Role ${var.name_ecs_task_role}"
  policy      = data.aws_iam_policy_document.role_policy_ecs_task_execution_role.json

  lifecycle {
    create_before_destroy = true
  }
}

# ------- IAM Policies Attachments -------
resource "aws_iam_role_policy_attachment" "ecs_attachment" {
  policy_arn = aws_iam_policy.policy_for_ecs_task_role.arn
  role       = aws_iam_role.ecs_task_role.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_excecution_role.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  policy_arn = aws_iam_policy.policy_for_ecs_task_role.arn
  role       = aws_iam_role.ecs_task_excecution_role.name

  lifecycle {
    create_before_destroy = true
  }
}
data "aws_iam_policy_document" "role_policy_ecs_task_role" {
  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "role_policy_ecs_task_execution_role" {
  statement {
    sid    = "AllowActions"
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}
