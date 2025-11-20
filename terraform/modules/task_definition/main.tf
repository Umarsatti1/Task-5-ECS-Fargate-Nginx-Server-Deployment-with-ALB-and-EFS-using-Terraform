# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.task_exec_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# ECS Task Execution IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom ECS and EFS Access IAM Policy
resource "aws_iam_policy" "efs_policy" {
  name        = var.efs_policy_name
  description = "Custom policy which allows ECS tasks to mount and access EFS file systems"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:DescribeMountTargets",
        "elasticfilesystem:DescribeFileSystems"
      ],
      Resource = "*"
    }]
  })
}

# Custom ECS and EFS Access IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_efs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.efs_policy.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = var.logs_name
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.task_definition_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = var.volume_name

    efs_volume_configuration {
      file_system_id          = var.efs_fs_id
      transit_encryption      = "ENABLED"
      
      authorization_config {
        access_point_id = var.efs_ap_id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      cpu       = 200
      memory    = 512

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = var.volume_name
          containerPath = "/mnt/data"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}
