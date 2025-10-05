# Script para parar o ambiente
# Execute com: .\stop-environment.ps1

Write-Host "🛑 Parando ambiente de desenvolvimento..." -ForegroundColor Yellow
Write-Host ""

# Parar containers
Write-Host "📦 Parando containers Docker..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "✅ Ambiente parado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Dica: Para remover também os volumes (limpar dados), execute:" -ForegroundColor Cyan
Write-Host "   docker-compose down -v" -ForegroundColor Yellow
Write-Host ""
