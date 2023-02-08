/*=============================
        AWS ECS Cluster
===============================*/

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "cluster-${var.name}"
}