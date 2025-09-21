# Outputs importantes
output "load_balancer_url" {
  description = "URL do Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.main.name
}

output "security_group_alb_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "security_group_ecs_id" {
  description = "ID do Security Group do ECS"
  value       = aws_security_group.ecs_tasks.id
}