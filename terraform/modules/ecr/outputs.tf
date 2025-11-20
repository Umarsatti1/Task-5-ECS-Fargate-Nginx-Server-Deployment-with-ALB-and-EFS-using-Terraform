output "ecr_repo_url" {
    value = aws_ecr_repository.nginx_repo.repository_url
}
