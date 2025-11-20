output "ecr_repo_url" {
    value       = module.ecr.ecr_repo_url
    description = "ECR Private repository URI"
}

output "alb_dns_name" {
    value       = module.alb.alb_dns_name
    description = "ALB DNS Name to access web application"
}