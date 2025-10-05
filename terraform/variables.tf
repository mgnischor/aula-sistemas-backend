# Variáveis gerais
variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "aula-sistemas-backend"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

# Variáveis de rede
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.32.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks para as subnets públicas"
  type        = list(string)
  default     = ["10.32.1.0/24", "10.32.2.0/24"]
}

# Variáveis da aplicação
variable "container_port" {
  description = "Porta do container"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path para health check"
  type        = string
  default     = "/"
}

# Variáveis do Fargate
variable "fargate_cpu" {
  description = "CPU do Fargate (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"  # Reduzido de 512 para economizar custos
}

variable "fargate_memory" {
  description = "Memória do Fargate em MiB"
  type        = string
  default     = "512"  # Reduzido de 1024 para economizar custos
}

variable "app_count" {
  description = "Número de instâncias da aplicação"
  type        = number
  default     = 1  # Reduzido de 2 para economizar custos
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs do CloudWatch"
  type        = number
  default     = 3  # Reduzido de 7 para economizar custos
}

variable "enable_ecr_scan" {
  description = "Habilitar scan de segurança no ECR (gera custos)"
  type        = bool
  default     = false  # Desabilitado para economizar custos
}