resource "aws_ecs_cluster" "main" {
  name = "devops-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "devops-ecs-cluster"
  }
}



resource "aws_ecs_task_definition" "app" {
  family                   = "devops-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "devops-app"
      image     = "996028738165.dkr.ecr.us-east-1.amazonaws.com/devops-frontend"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


