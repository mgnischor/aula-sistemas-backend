# 🚀 Deploy AWS com Terraform

Este diretório contém a configuração Terraform para fazer deploy do backend `aula-sistemas-backend` na AWS usando ECS Fargate.

## 📋 Arquitetura

- **ECS Fargate**: Execução serverless dos containers
- **ECR**: Registry para imagens Docker
- **Application Load Balancer**: Distribição de tráfego
- **VPC**: Rede isolada com subnets públicas
- **CloudWatch**: Logs da aplicação
- **Security Groups**: Controle de acesso

## 🛠️ Pré-requisitos

1. **AWS CLI** instalado e configurado
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.0
   ```bash
   # Windows (Chocolatey)
   choco install terraform
   
   # Ou baixe em: https://www.terraform.io/downloads
   ```

3. **Docker** instalado e rodando
   ```bash
   docker --version
   ```

## ⚡ Deploy Rápido

### Opção 1: Deploy Completo Automático
```powershell
# Execute da raiz do projeto
.\terraform\deploy-complete.ps1
```

### Opção 2: Passo a Passo

1. **Configure as variáveis** (opcional):
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edite terraform.tfvars conforme necessário
   ```

2. **Inicialize o Terraform**:
   ```bash
   terraform init
   ```

3. **Planeje o deployment**:
   ```bash
   terraform plan
   ```

4. **Aplique a infraestrutura**:
   ```bash
   terraform apply
   ```

5. **Deploy da aplicação**:
   ```powershell
   .\deploy-image.ps1
   ```

## 📁 Estrutura dos Arquivos

```
terraform/
├── main.tf                    # Configuração principal
├── variables.tf               # Variáveis de entrada
├── outputs.tf                 # Outputs importantes
├── terraform.tfvars.example   # Exemplo de configuração
├── deploy-image.ps1          # Script de deploy da imagem
├── deploy-image.sh           # Script de deploy (Linux/Mac)
├── deploy-complete.ps1       # Deploy completo
└── README.md                 # Esta documentação
```

## ⚙️ Configurações Disponíveis

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `project_name` | Nome do projeto | `aula-sistemas-backend` |
| `environment` | Ambiente | `prod` |
| `aws_region` | Região AWS | `us-east-1` |
| `vpc_cidr` | CIDR da VPC | `10.32.0.0/16` |
| `container_port` | Porta do container | `8080` |
| `fargate_cpu` | CPU do Fargate | `512` |
| `fargate_memory` | Memória do Fargate | `1024` |
| `app_count` | Número de instâncias | `2` |

## 🔧 Comandos Úteis

### Verificar logs da aplicação:
```bash
aws logs tail /ecs/aula-sistemas-backend --follow --region us-east-1
```

### Forçar novo deployment:
```bash
aws ecs update-service \
  --cluster aula-sistemas-backend-cluster \
  --service aula-sistemas-backend-service \
  --force-new-deployment
```

### Escalar aplicação:
```bash
aws ecs update-service \
  --cluster aula-sistemas-backend-cluster \
  --service aula-sistemas-backend-service \
  --desired-count 4
```

### Ver status do serviço:
```bash
aws ecs describe-services \
  --cluster aula-sistemas-backend-cluster \
  --services aula-sistemas-backend-service
```

## 🗑️ Destruir Infraestrutura

```bash
cd terraform
terraform destroy
```

## 💰 Estimativa de Custos

Para 2 instâncias Fargate (512 CPU, 1024 MB):
- **ECS Fargate**: ~$25-30/mês
- **Application Load Balancer**: ~$16/mês
- **ECR**: ~$1/mês (para 1GB)
- **CloudWatch Logs**: ~$1-5/mês
- **Total**: ~$43-52/mês

## 🔐 Configuração de CORS

O backend está configurado para aceitar requisições de:
- `http://localhost:4200` (Angular dev)
- `http://localhost:3000` (React dev)

Para adicionar mais origens, edite o arquivo `Program.cs`:

```csharp
policy.WithOrigins("http://localhost:4200", "https://meufront.com")
```

## 🚨 Troubleshooting

### Erro de login no ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-url>
```

### Service não inicia
1. Verificar logs no CloudWatch
2. Verificar security groups
3. Verificar health check path

### Timeout no health check
- Certifique-se que a aplicação responde na porta 8080
- Verifique se o health check path está correto

## 📞 Suporte

Para problemas:
1. Verificar logs no CloudWatch
2. Verificar status do ECS Service
3. Verificar security groups e target groups

## 🎯 Próximos Passos

- [ ] Configurar HTTPS com certificado SSL
- [ ] Adicionar banco de dados RDS
- [ ] Configurar auto-scaling
- [ ] Implementar CI/CD com GitHub Actions
- [ ] Configurar domínio customizado