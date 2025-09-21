# Script PowerShell para fazer build e push da imagem Docker para ECR
# Uso: .\deploy-image.ps1 [-Profile "default"] [-Region "us-east-1"]

param(
    [string]$Profile = "default",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

# Configurações
$ProjectName = "aula-sistemas-backend"

Write-Host "🚀 Iniciando deployment da imagem Docker..." -ForegroundColor Green
Write-Host "📋 Projeto: $ProjectName" -ForegroundColor Cyan
Write-Host "🔧 Profile AWS: $Profile" -ForegroundColor Cyan
Write-Host "🌍 Região AWS: $Region" -ForegroundColor Cyan

# Verificar se o Terraform já foi aplicado
if (!(Test-Path "terraform\terraform.tfstate")) {
    Write-Host "❌ Terraform state não encontrado. Execute 'terraform apply' primeiro!" -ForegroundColor Red
    exit 1
}

# Obter a URL do ECR
Write-Host "📋 Obtendo informações do Terraform..." -ForegroundColor Yellow
Push-Location terraform
try {
    $EcrUrl = terraform output -raw ecr_repository_url
    if ([string]::IsNullOrEmpty($EcrUrl)) {
        throw "Não foi possível obter a URL do ECR repository"
    }
} catch {
    Write-Host "❌ Erro ao obter URL do ECR: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

Write-Host "📦 ECR Repository: $EcrUrl" -ForegroundColor Cyan

# Login no ECR
Write-Host "🔐 Fazendo login no ECR..." -ForegroundColor Yellow
try {
    $LoginToken = aws ecr get-login-password --region $Region --profile $Profile
    $LoginToken | docker login --username AWS --password-stdin $EcrUrl
} catch {
    Write-Host "❌ Erro no login ECR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Build da imagem
Write-Host "🏗️  Fazendo build da imagem Docker..." -ForegroundColor Yellow
try {
    docker build -t $ProjectName .
} catch {
    Write-Host "❌ Erro no build: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Tag da imagem
Write-Host "🏷️  Criando tag para ECR..." -ForegroundColor Yellow
docker tag "${ProjectName}:latest" "${EcrUrl}:latest"

# Push da imagem
Write-Host "📤 Fazendo push para ECR..." -ForegroundColor Yellow
try {
    docker push "${EcrUrl}:latest"
} catch {
    Write-Host "❌ Erro no push: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Imagem enviada com sucesso!" -ForegroundColor Green

# Forçar nova deployment no ECS
Write-Host "🔄 Forçando novo deployment no ECS..." -ForegroundColor Yellow
Push-Location terraform
try {
    $ClusterName = terraform output -raw ecs_cluster_name
    $ServiceName = terraform output -raw ecs_service_name
    
    aws ecs update-service `
        --cluster $ClusterName `
        --service $ServiceName `
        --force-new-deployment `
        --region $Region `
        --profile $Profile | Out-Null
        
    Write-Host "✅ Deployment da aplicação iniciado!" -ForegroundColor Green
    
    # Obter URL do Load Balancer
    $LbUrl = terraform output -raw load_balancer_url
    Write-Host "🌐 Aplicação disponível em: $LbUrl" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro no deployment ECS: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "🎉 Deploy concluído com sucesso!" -ForegroundColor Green