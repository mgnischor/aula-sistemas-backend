# Otimização de Custos - Terraform AWS

## 🎯 Objetivo

Este documento descreve as otimizações aplicadas à infraestrutura AWS para reduzir custos operacionais, mantendo a funcionalidade da aplicação.

## 💰 Otimizações Implementadas

### 1. **Recursos do Fargate**

**Antes:**

-   CPU: 512 (0.5 vCPU)
-   Memória: 1024 MB
-   **Custo estimado:** ~$0.04048/hora por task

**Depois:**

-   CPU: 256 (0.25 vCPU) ⬇️ **50% de redução**
-   Memória: 512 MB ⬇️ **50% de redução**
-   **Custo estimado:** ~$0.02024/hora por task

**💵 Economia:** ~$0.02024/hora por task = **~$14.57/mês por instância** (50% de economia)

---

### 2. **Número de Instâncias**

**Antes:**

-   app_count: 2 instâncias

**Depois:**

-   app_count: 1 instância ⬇️ **50% de redução**

**💵 Economia:** ~$14.57/mês adicional

**⚠️ Nota:** Para ambientes de produção com alta disponibilidade, considere manter 2+ instâncias.

---

### 3. **Retenção de Logs CloudWatch**

**Antes:**

-   Retenção: 7 dias

**Depois:**

-   Retenção: 3 dias ⬇️ **~43% de redução**

**💵 Economia:** Redução no armazenamento de logs (~$0.03/GB armazenado/mês)

---

### 4. **Scan de Imagens ECR**

**Antes:**

-   Scan de segurança habilitado (scan_on_push = true)
-   Custo: $0.09 por scan

**Depois:**

-   Scan de segurança desabilitado (enable_ecr_scan = false) ⬇️ **100% de redução**

**💵 Economia:** ~$2-5/mês (dependendo da frequência de deploys)

**⚠️ Nota:** Para produção, considere habilitar scans periódicos por segurança.

---

### 5. **Retenção de Imagens ECR**

**Antes:**

-   Manter últimas 10 imagens

**Depois:**

-   Manter últimas 5 imagens ⬇️ **50% de redução**

**💵 Economia:** ~$0.10/GB/mês de armazenamento ECR

---

### 6. **Criptografia de Logs ECS**

**Antes:**

-   Criptografia habilitada (cloud_watch_encryption_enabled = true)

**Depois:**

-   Criptografia desabilitada (cloud_watch_encryption_enabled = false) ⬇️ **100% de redução**

**💵 Economia:** Eliminação do custo de KMS (~$1/mês por chave + $0.03/10.000 requisições)

---

## 📊 Resumo da Economia Mensal

| Item                           | Economia Mensal (USD) |
| ------------------------------ | --------------------- |
| Recursos Fargate (CPU/Memória) | $14.57                |
| Redução de instâncias (2→1)    | $14.57                |
| Retenção de logs (7→3 dias)    | $1-3                  |
| Scan ECR desabilitado          | $2-5                  |
| Retenção imagens ECR (10→5)    | $0.50-2               |
| Criptografia logs desabilitada | $1-2                  |
| **TOTAL ESTIMADO**             | **$34-44/mês**        |

### 💡 Economia Anual: **~$408-528/ano**

---

## 🔧 Configuração Recomendada por Ambiente

### **Ambiente de Desenvolvimento/Teste**

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 1
log_retention_days = 3
enable_ecr_scan    = false
```

**Custo estimado:** ~$15-20/mês

### **Ambiente de Staging**

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 1
log_retention_days = 7
enable_ecr_scan    = false
```

**Custo estimado:** ~$18-23/mês

### **Ambiente de Produção (Mínimo)**

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 2
log_retention_days = 7
enable_ecr_scan    = true
```

**Custo estimado:** ~$35-45/mês

### **Ambiente de Produção (Alta Disponibilidade)**

```hcl
fargate_cpu        = "512"
fargate_memory     = "1024"
app_count          = 2
log_retention_days = 14
enable_ecr_scan    = true
```

**Custo estimado:** ~$70-90/mês

---

## ⚡ Aplicando as Otimizações

### 1. **Revisar configurações**

Edite o arquivo `terraform.tfvars` com os valores desejados:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars conforme necessário
```

### 2. **Validar mudanças**

```bash
terraform plan
```

### 3. **Aplicar otimizações**

```bash
terraform apply
```

---

## ⚠️ Considerações Importantes

### **Performance**

-   Recursos reduzidos (256 CPU/512 MB) são suficientes para aplicações leves
-   Monitore o uso de CPU/memória após o deploy
-   Se CPU > 70% consistentemente, considere aumentar para 512 CPU/1024 MB

### **Disponibilidade**

-   **1 instância:** Sem redundância, adequado para dev/test
-   **2+ instâncias:** Recomendado para produção para alta disponibilidade

### **Segurança**

-   Scan ECR desabilitado reduz custos mas remove verificação automática de vulnerabilidades
-   Para produção, considere habilitar ou usar ferramentas alternativas

### **Logs**

-   3 dias de retenção é adequado para troubleshooting imediato
-   Para compliance/auditoria, considere aumentar ou exportar para S3

---

## 📈 Monitoramento de Custos

### **CloudWatch Metrics**

Monitore estas métricas para otimização contínua:

-   `CPUUtilization` (ECS)
-   `MemoryUtilization` (ECS)
-   `RequestCount` (ALB)
-   `HealthyHostCount` (ALB)

### **AWS Cost Explorer**

Configure alertas para:

-   Custo mensal > $50
-   Aumento de custo > 20% semana-a-semana

### **Tags de Custo**

Todos os recursos incluem tags:

```hcl
tags = {
  Name        = "${var.project_name}-*"
  Environment = var.environment
}
```

Use estas tags no Cost Explorer para rastrear custos por ambiente.

---

## 🔄 Próximas Otimizações Possíveis

1. **Spot Instances** (Fargate Spot): 70% de economia
2. **Reserved Capacity**: 30-50% de economia com compromisso de 1-3 anos
3. **S3 Lifecycle para logs**: Mover logs antigos para Glacier
4. **NAT Gateway**: Usar NAT Instances se necessário (economiza ~$32/mês)
5. **CloudFront**: CDN para reduzir tráfego ALB

---

## 📚 Recursos Adicionais

-   [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
-   [CloudWatch Pricing](https://aws.amazon.com/cloudwatch/pricing/)
-   [ECR Pricing](https://aws.amazon.com/ecr/pricing/)
-   [AWS Cost Optimization Best Practices](https://aws.amazon.com/pricing/cost-optimization/)

---

**Última atualização:** 2025-10-04
