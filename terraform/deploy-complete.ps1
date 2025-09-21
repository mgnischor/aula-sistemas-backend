# Script PowerShell para deploy completo na AWS
# Uso: .\deploy-complete.ps1 [-Profile "default"] [-Region "us-east-1"]

param(
    [string]$Profile = "default",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Iniciando deploy completo na AWS..." -ForegroundColor Green
Write-Host "🔧 Profile AWS: $Profile" -ForegroundColor Cyan
Write-Host "🌍 Região AWS: $Region" -ForegroundColor Cyan

# Verificar se AWS CLI está instalado
try {
    aws --version | Out-Null
} catch {
    Write-Host "❌ AWS CLI não encontrado. Instale o AWS CLI primeiro!" -ForegroundColor Red
    exit 1
}

# Verificar se Terraform está instalado
try {
    terraform version | Out-Null
} catch {
    Write-Host "❌ Terraform não encontrado. Instale o Terraform primeiro!" -ForegroundColor Red
    exit 1
}

# Verificar se Docker está instalado
try {
    docker version | Out-Null
} catch {
    Write-Host "❌ Docker não encontrado. Instale o Docker primeiro!" -ForegroundColor Red
    exit 1
}

# Navegar para o diretório terraform
Push-Location terraform

try {
    # Inicializar Terraform
    Write-Host "🏗️  Inicializando Terraform..." -ForegroundColor Yellow
    terraform init

    # Planejar deployment
    Write-Host "📋 Planejando deployment..." -ForegroundColor Yellow
    terraform plan -var="aws_region=$Region"

    # Confirmar deployment
    $confirmation = Read-Host "🤔 Continuar com o deployment? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Deployment cancelado pelo usuário." -ForegroundColor Red
        exit 0
    }

    # Aplicar infraestrutura
    Write-Host "🚧 Criando infraestrutura..." -ForegroundColor Yellow
    terraform apply -var="aws_region=$Region" -auto-approve

    # Obter outputs
    $EcrUrl = terraform output -raw ecr_repository_url
    $LbUrl = terraform output -raw load_balancer_url

    Write-Host "✅ Infraestrutura criada com sucesso!" -ForegroundColor Green
    Write-Host "📦 ECR Repository: $EcrUrl" -ForegroundColor Cyan
    Write-Host "🌐 Load Balancer: $LbUrl" -ForegroundColor Cyan

} catch {
    Write-Host "❌ Erro no Terraform: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# Fazer build e push da imagem
Write-Host "📦 Fazendo build e deploy da aplicação..." -ForegroundColor Yellow
.\terraform\deploy-image.ps1 -Profile $Profile -Region $Region

Write-Host "🎉 Deploy completo finalizado!" -ForegroundColor Green
Write-Host "⏰ A aplicação pode levar alguns minutos para ficar disponível..." -ForegroundColor Yellow

# Mostrar informações finais
Push-Location terraform
try {
    $LbUrl = terraform output -raw load_balancer_url
    Write-Host ""
    Write-Host "📋 INFORMAÇÕES DO DEPLOYMENT:" -ForegroundColor Green
    Write-Host "🌐 URL da Aplicação: $LbUrl" -ForegroundColor Cyan
    Write-Host "📝 Para verificar logs: aws logs tail /ecs/aula-sistemas-backend --follow --region $Region --profile $Profile" -ForegroundColor Cyan
    Write-Host "🗑️  Para destruir: terraform destroy" -ForegroundColor Yellow
} finally {
    Pop-Location
}