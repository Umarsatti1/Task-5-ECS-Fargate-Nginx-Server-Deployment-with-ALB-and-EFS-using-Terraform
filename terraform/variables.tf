# VPC Variables
variable "vpc_name" {
    type        = string
    description = "VPC Name"
}

variable "vpc_cidr" {
    type        = string
    description = "VPC IPv4 CIDR Block"
}

# ECR Variables
variable "ecr_repo_name" {
    type        = string
    description = "NGINX ECR repository name"
}

# ECS Variables
variable "cluster_name" {
    type        = string
    description = "ECS Cluster name"
}

variable "service_name" {
    type        = string
    description = "ECS Service name"
}

variable "container_name" {
    type        = string
    description = "NGINX Container name"
}

# EFS Variables
variable "token" {
    type        = string
    description = "EFS file system creation token name"
}

variable "efs_name" {
    type        = string
    description = "EFS file system name tag"
}

variable "access_point_name" {
    type        = string
    description = "EFS access point name"
}

# Task Definition Variables
variable "task_exec_name" {
  type = string
  description = "Task Execution IAM Role name"
}

variable "efs_policy_name" {
  type = string
  description = "EFS IAM policy name"
}

variable "logs_name" {
  type = string
  description = "ECS CloudWatch Logs group"
}

variable "task_definition_name" {
  type = string
  description = "Task definition name"
}

variable "volume_name" {
  type        = string
  description = "EFS mount volume name"
}

# ALB and Target Group Variables
variable "target_group_port" {
    type        = number
    description = "Target Group port number"
}

variable "alb_name" {
    type        = string
    description = "Application Load Balancer name"
}

variable "lb_type" {
    type        = string
    description = "Load Balancer type"
}