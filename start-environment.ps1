# Script para iniciar o ambiente completo
# Execute com: .\start-environment.ps1

Write-Host "🚀 Iniciando ambiente de desenvolvimento..." -ForegroundColor Green
Write-Host ""

# Verificar se Docker está rodando
Write-Host "📦 Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✅ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está rodando. Por favor, inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Subir RabbitMQ
Write-Host "🐰 Iniciando RabbitMQ..." -ForegroundColor Yellow
docker-compose up -d rabbitmq

Write-Host ""
Write-Host "⏳ Aguardando RabbitMQ inicializar (15 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar se RabbitMQ está saudável
Write-Host "🔍 Verificando saúde do RabbitMQ..." -ForegroundColor Yellow
$rabbitHealthy = $false
for ($i = 1; $i -le 10; $i++) {
    $health = docker inspect --format='{{.State.Health.Status}}' rabbitmq 2>$null
    if ($health -eq "healthy") {
        $rabbitHealthy = $true
        break
    }
    Write-Host "   Tentativa $i/10... Status: $health" -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

if ($rabbitHealthy) {
    Write-Host "✅ RabbitMQ está saudável e pronto!" -ForegroundColor Green
} else {
    Write-Host "⚠️  RabbitMQ ainda está iniciando, mas vamos continuar..." -ForegroundColor Yellow
}

Write-Host ""

# Restaurar pacotes
Write-Host "📦 Restaurando pacotes NuGet..." -ForegroundColor Yellow
dotnet restore

Write-Host ""

# Compilar projeto
Write-Host "🔨 Compilando projeto..." -ForegroundColor Yellow
dotnet build

Write-Host ""
Write-Host "✅ Ambiente configurado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Informações úteis:" -ForegroundColor Cyan
Write-Host "   🌐 RabbitMQ Management UI: http://localhost:15672" -ForegroundColor White
Write-Host "      Usuário: guest" -ForegroundColor Gray
Write-Host "      Senha: guest" -ForegroundColor Gray
Write-Host ""
Write-Host "   🚀 Para iniciar a aplicação, execute:" -ForegroundColor White
Write-Host "      dotnet run" -ForegroundColor Yellow
Write-Host ""
Write-Host "   📝 Ou para desenvolvimento com hot reload:" -ForegroundColor White
Write-Host "      dotnet watch run" -ForegroundColor Yellow
Write-Host ""
Write-Host "   🧪 Teste as APIs usando:" -ForegroundColor White
Write-Host "      • Arquivo test-requests.http (VS Code REST Client)" -ForegroundColor Gray
Write-Host "      • Consulte QUICK_START.md para exemplos cURL" -ForegroundColor Gray
Write-Host ""
