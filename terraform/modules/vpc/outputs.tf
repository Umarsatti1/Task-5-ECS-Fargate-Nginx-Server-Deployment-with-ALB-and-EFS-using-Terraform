output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "public_subnets" {
    description = "VPC Public Subnet IDs"
    value       = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
    description = "VPC Private Subnet IDs"
    value       = [for s in aws_subnet.private : s.id]
}

output "efs_sg_id" {
    description = "EFS Private Security Group ID"
    value       = aws_security_group.efs_sg.id
}

output "ecs_sg_id" {
    description = "ECS Service Security Group ID"
    value       = aws_security_group.ecs_sg.id
}

output "alb_sg_id" {
    description = "ALB Security Group ID"
    value       = aws_security_group.alb_sg.id
}