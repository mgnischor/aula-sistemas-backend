#!/bin/bash

# Script para fazer build e push da imagem Docker para ECR
# Uso: ./deploy-image.sh [profile] [region]

set -e

# Configurações
PROJECT_NAME="aula-sistemas-backend"
AWS_PROFILE=${1:-default}
AWS_REGION=${2:-us-east-1}

echo "🚀 Iniciando deployment da imagem Docker..."
echo "📋 Projeto: $PROJECT_NAME"
echo "🔧 Profile AWS: $AWS_PROFILE"
echo "🌍 Região AWS: $AWS_REGION"

# Verificar se o Terraform já foi aplicado
if [ ! -f "terraform/terraform.tfstate" ]; then
    echo "❌ Terraform state não encontrado. Execute 'terraform apply' primeiro!"
    exit 1
fi

# Obter a URL do ECR
ECR_URL=$(cd terraform && terraform output -raw ecr_repository_url)
if [ -z "$ECR_URL" ]; then
    echo "❌ Não foi possível obter a URL do ECR repository"
    exit 1
fi

echo "📦 ECR Repository: $ECR_URL"

# Login no ECR
echo "🔐 Fazendo login no ECR..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $ECR_URL

# Build da imagem
echo "🏗️  Fazendo build da imagem Docker..."
docker build -t $PROJECT_NAME .

# Tag da imagem
echo "🏷️  Criando tag para ECR..."
docker tag $PROJECT_NAME:latest $ECR_URL:latest

# Push da imagem
echo "📤 Fazendo push para ECR..."
docker push $ECR_URL:latest

echo "✅ Imagem enviada com sucesso!"

# Forçar nova deployment no ECS
echo "🔄 Forçando novo deployment no ECS..."
CLUSTER_NAME=$(cd terraform && terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(cd terraform && terraform output -raw ecs_service_name)

aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --force-new-deployment \
    --region $AWS_REGION \
    --profile $AWS_PROFILE > /dev/null

echo "✅ Deployment da aplicação iniciado!"

# Obter URL do Load Balancer
LB_URL=$(cd terraform && terraform output -raw load_balancer_url)
echo "🌐 Aplicação disponível em: $LB_URL"

echo "🎉 Deploy concluído com sucesso!"