# VPC Variables
vpc_name = "ecs-efs-vpc"
vpc_cidr = "10.0.0.0/16"

# ECR Variables
ecr_repo_name = "nginx-repo"

# ECS Variables
cluster_name   = "nginx-ecs-cluster"
service_name   = "nginx-service"
container_name = "nginx"

# EFS Variables
token             = "efs-nginx-token"
efs_name          = "efs-nginx"
access_point_name = "efs-nginx-access-point"

# Task Definition Variables
task_exec_name       = "ECS-Task-Execution-Role"
efs_policy_name      = "ECS-EFS-Access-Policy"
logs_name            = "/ecs/nginx-container-app"
task_definition_name = "nginx-task-definition"
volume_name          = "nginx-efs-volume"

# ALB Variables
target_group_port = 80
alb_name          = "nginx-ecs-alb"
lb_type           = "application"