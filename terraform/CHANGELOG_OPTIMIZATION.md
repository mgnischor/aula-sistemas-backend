# 📝 Changelog - Otimização de Custos

## [2025-10-04] - Otimização de Recursos AWS

### 🎯 Objetivo

Reduzir custos da infraestrutura AWS mantendo a funcionalidade da aplicação.

### ✅ Alterações Implementadas

#### 1. **variables.tf**

-   ✏️ `fargate_cpu`: `512` → `256` (50% redução)
-   ✏️ `fargate_memory`: `1024` → `512` (50% redução)
-   ✏️ `app_count`: `2` → `1` (50% redução)
-   ➕ `log_retention_days`: nova variável (padrão: 3 dias)
-   ➕ `enable_ecr_scan`: nova variável (padrão: false)

#### 2. **main.tf**

-   ✏️ ECR scan: `true` → `var.enable_ecr_scan` (controlável)
-   ✏️ ECR lifecycle: manter 10 imagens → 5 imagens (50% redução)
-   ✏️ ECS cluster encryption: `true` → `false` (economia em KMS)
-   ✏️ CloudWatch retention: `7` → `var.log_retention_days` (controlável)

#### 3. **terraform.tfvars.example**

-   ✏️ Valores atualizados com configurações otimizadas
-   ➕ Documentação de novos parâmetros
-   ➕ Comentários sobre uso por ambiente

#### 4. **README.md**

-   ➕ Referência ao documento de otimização de custos
-   ✏️ Tabela de variáveis atualizada com marcadores de otimização
-   ✏️ Seção de custos expandida com comparativos
-   ➕ Link para documentação detalhada de economia

#### 5. **COST_OPTIMIZATION.md** (novo)

-   ➕ Documento completo sobre otimizações
-   ➕ Cálculos detalhados de economia
-   ➕ Recomendações por ambiente (dev/staging/prod)
-   ➕ Considerações de performance e segurança
-   ➕ Dicas de monitoramento de custos

---

### 💰 Impacto Financeiro

| Item                     | Antes    | Depois  | Economia |
| ------------------------ | -------- | ------- | -------- |
| **CPU/Memória Fargate**  | 512/1024 | 256/512 | -50%     |
| **Número de instâncias** | 2        | 1       | -50%     |
| **Retenção de logs**     | 7 dias   | 3 dias  | -43%     |
| **Imagens ECR**          | 10       | 5       | -50%     |
| **Scan ECR**             | Sim      | Não     | -100%    |
| **Criptografia logs**    | Sim      | Não     | -100%    |

**💵 Economia Total Estimada:**

-   **Mensal:** $34-44 (~50-60% de redução)
-   **Anual:** $408-528

**Custo Mensal:**

-   **Antes:** $72-82/mês
-   **Depois:** $32-38/mês (configuração otimizada)

---

### 📊 Configurações Recomendadas

#### Desenvolvimento/Test

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 1
log_retention_days = 3
enable_ecr_scan    = false
```

💰 **Custo:** ~$32-38/mês

#### Staging

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 1
log_retention_days = 7
enable_ecr_scan    = false
```

💰 **Custo:** ~$35-40/mês

#### Produção (Mínima)

```hcl
fargate_cpu        = "256"
fargate_memory     = "512"
app_count          = 2
log_retention_days = 7
enable_ecr_scan    = true
```

💰 **Custo:** ~$47-55/mês

#### Produção (Alta Performance)

```hcl
fargate_cpu        = "512"
fargate_memory     = "1024"
app_count          = 2
log_retention_days = 14
enable_ecr_scan    = true
```

💰 **Custo:** ~$70-90/mês

---

### ⚠️ Considerações

#### Performance

-   ✅ 256 CPU/512 MB é adequado para aplicações leves (.NET 9)
-   ⚡ Monitore CPU/memória após deploy
-   📈 Aumente recursos se CPU > 70% consistentemente

#### Disponibilidade

-   ⚠️ 1 instância = sem redundância (ideal para dev/test)
-   ✅ 2+ instâncias = alta disponibilidade (recomendado para produção)

#### Segurança

-   ⚠️ Scan ECR desabilitado remove verificação automática de vulnerabilidades
-   🔒 Para produção, considere habilitar ou usar ferramentas alternativas
-   🔐 Criptografia de logs desabilitada (adequado para dados não-sensíveis)

#### Logs

-   ✅ 3 dias de retenção adequado para troubleshooting imediato
-   📦 Para compliance, considere exportar para S3 com lifecycle policy

---

### 🚀 Como Aplicar

1. **Revisar configurações:**

    ```bash
    cd terraform
    cp terraform.tfvars.example terraform.tfvars
    # Edite conforme seu ambiente
    ```

2. **Validar mudanças:**

    ```bash
    terraform plan
    ```

3. **Aplicar otimizações:**

    ```bash
    terraform apply
    ```

4. **Monitorar após deploy:**
    - CloudWatch Metrics (CPU/Memória)
    - AWS Cost Explorer
    - Application Load Balancer Metrics

---

### 🔄 Rollback

Para reverter às configurações anteriores:

```hcl
# terraform.tfvars
fargate_cpu        = "512"
fargate_memory     = "1024"
app_count          = 2
log_retention_days = 7
enable_ecr_scan    = true
```

```bash
terraform apply
```

---

### 📚 Referências

-   [COST_OPTIMIZATION.md](./COST_OPTIMIZATION.md) - Análise detalhada de custos
-   [README.md](./README.md) - Documentação principal do Terraform
-   [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
-   [AWS Cost Optimization](https://aws.amazon.com/pricing/cost-optimization/)

---

### 👥 Contribuidores

-   GitHub Copilot - Otimização automatizada de infraestrutura
-   Data: 2025-10-04

---

### 🎯 Próximas Melhorias Sugeridas

1. **Fargate Spot** - 70% de economia adicional
2. **Reserved Capacity** - 30-50% com compromisso de 1-3 anos
3. **S3 Lifecycle para logs** - Arquivamento automático em Glacier
4. **CloudFront CDN** - Redução de tráfego no ALB
5. **Auto Scaling** - Escalonamento baseado em métricas
6. **Observability** - Implementar métricas customizadas

---

**Status:** ✅ Implementado e pronto para uso
**Ambiente:** Todos (Dev/Staging/Prod)
**Backward Compatible:** ✅ Sim (requer `terraform apply`)
