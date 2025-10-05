# 📖 Guia de Navegação - Documentação do Projeto

Bem-vindo! Este projeto foi adaptado para usar RabbitMQ como sistema de mensageria. Escolha por onde começar:

## 🚀 Início Rápido

**Quer começar AGORA?**
👉 Leia: [`QUICK_START.md`](QUICK_START.md)

Ou execute:

```powershell
.\start-environment.ps1
dotnet run
```

---

## 📚 Documentação por Objetivo

### 🎯 "Quero entender o que foi feito"

📄 [`README.md`](README.md) - Resumo executivo  
📄 [`SUMMARY.md`](SUMMARY.md) - Resumo detalhado completo

### 🏗️ "Quero entender a arquitetura"

📐 [`ARCHITECTURE.md`](ARCHITECTURE.md) - Diagramas e arquitetura visual

-   Fluxos de dados
-   Estrutura de pastas
-   Padrões implementados

### 🚀 "Quero rodar o sistema"

⚡ [`QUICK_START.md`](QUICK_START.md) - Comandos para iniciar  
📋 [`VERIFICATION_CHECKLIST.md`](VERIFICATION_CHECKLIST.md) - Passo a passo para testar

### 🔍 "Quero monitorar e debugar"

🔧 [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md) - Guia completo de monitoramento

-   Como usar Management UI
-   Comandos Docker úteis
-   Troubleshooting

### 📖 "Quero documentação completa do RabbitMQ"

📚 [`README_RABBITMQ.md`](README_RABBITMQ.md) - Documentação detalhada

-   Configurações
-   Como funciona
-   Casos de uso

### 🧪 "Quero testar a API"

📝 [`test-requests.http`](test-requests.http) - Requisições prontas  
(Use com VS Code REST Client Extension)

### 🛠️ "Quero scripts prontos"

🎬 [`start-environment.ps1`](start-environment.ps1) - Iniciar tudo  
🛑 [`stop-environment.ps1`](stop-environment.ps1) - Parar tudo

---

## 📊 Estrutura da Documentação

```
📁 Documentação
│
├── 📄 README.md ⭐ COMECE AQUI
│   └── Resumo executivo rápido
│
├── 📄 QUICK_START.md 🚀 INÍCIO RÁPIDO
│   └── Comandos para rodar
│
├── 📄 VERIFICATION_CHECKLIST.md ✅ TESTE TUDO
│   └── Checklist completo de verificação
│
├── 📄 ARCHITECTURE.md 🏗️ ARQUITETURA
│   └── Diagramas e fluxos visuais
│
├── 📄 MONITORING_DEBUG.md 🔍 DEBUG
│   └── Como monitorar e resolver problemas
│
├── 📄 README_RABBITMQ.md 📚 DOCUMENTAÇÃO COMPLETA
│   └── Tudo sobre RabbitMQ neste projeto
│
├── 📄 SUMMARY.md 📋 RESUMO DETALHADO
│   └── Lista de tudo que foi implementado
│
├── 📄 NAVIGATION.md 📖 ESTE ARQUIVO
│   └── Guia de navegação
│
├── 📄 test-requests.http 🧪 TESTES
│   └── Requisições HTTP prontas
│
├── 🎬 start-environment.ps1
│   └── Script para iniciar
│
└── 🛑 stop-environment.ps1
    └── Script para parar
```

---

## 🎓 Roteiros de Aprendizado

### 👶 Iniciante - "Nunca usei RabbitMQ"

1. 📄 Leia [`README.md`](README.md) - 5 min
2. 🚀 Execute [`QUICK_START.md`](QUICK_START.md) - 10 min
3. ✅ Teste com [`VERIFICATION_CHECKLIST.md`](VERIFICATION_CHECKLIST.md) - 20 min
4. 🏗️ Entenda com [`ARCHITECTURE.md`](ARCHITECTURE.md) - 15 min

**Total: ~50 minutos para dominar o básico**

---

### 🧑‍💻 Intermediário - "Já usei message queues"

1. 📄 Leia [`SUMMARY.md`](SUMMARY.md) - 10 min
2. 🏗️ Estude [`ARCHITECTURE.md`](ARCHITECTURE.md) - 15 min
3. 📚 Aprofunde com [`README_RABBITMQ.md`](README_RABBITMQ.md) - 20 min
4. 🔍 Explore [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md) - 15 min

**Total: ~60 minutos para domínio avançado**

---

### 🚀 Avançado - "Vou usar em produção"

1. 📚 Leia toda documentação
2. 🔍 Foque em [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md)
3. 🏗️ Analise padrões em [`ARCHITECTURE.md`](ARCHITECTURE.md)
4. ✅ Execute todos os testes em [`VERIFICATION_CHECKLIST.md`](VERIFICATION_CHECKLIST.md)
5. 📝 Implemente casos de uso específicos

**Adicione**:

-   Dead Letter Queue
-   Publisher Confirms
-   Health Checks
-   Métricas (Prometheus)
-   Circuit Breaker

---

## 🎯 Perguntas Frequentes

### ❓ "Como inicio o sistema?"

👉 Execute `.\start-environment.ps1` e depois `dotnet run`  
📖 Detalhes em [`QUICK_START.md`](QUICK_START.md)

### ❓ "Como testo a API?"

👉 Use o arquivo [`test-requests.http`](test-requests.http)  
📖 Ou veja exemplos em [`QUICK_START.md`](QUICK_START.md)

### ❓ "Como vejo as mensagens no RabbitMQ?"

👉 Acesse http://localhost:15672  
📖 Guia completo em [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md)

### ❓ "Por que mensagens não são consumidas?"

👉 Veja seção Troubleshooting  
📖 Em [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md)

### ❓ "Como adiciono um novo tipo de evento?"

👉 Veja seção "Desenvolvimento"  
📖 Em [`README_RABBITMQ.md`](README_RABBITMQ.md)

### ❓ "Como escalo o sistema?"

👉 Veja seção "Escalabilidade"  
📖 Em [`ARCHITECTURE.md`](ARCHITECTURE.md)

---

## 🔗 Links Rápidos

| Ação                         | Arquivo                                                  |
| ---------------------------- | -------------------------------------------------------- |
| 🚀 Iniciar sistema           | [`QUICK_START.md`](QUICK_START.md)                       |
| ✅ Testar tudo               | [`VERIFICATION_CHECKLIST.md`](VERIFICATION_CHECKLIST.md) |
| 🔍 Debugar                   | [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md)             |
| 🏗️ Ver arquitetura           | [`ARCHITECTURE.md`](ARCHITECTURE.md)                     |
| 📚 Ler documentação completa | [`README_RABBITMQ.md`](README_RABBITMQ.md)               |
| 📋 Ver resumo                | [`SUMMARY.md`](SUMMARY.md)                               |
| 🧪 Testar API                | [`test-requests.http`](test-requests.http)               |

---

## 🛠️ Comandos Mais Usados

```powershell
# Iniciar ambiente completo
.\start-environment.ps1

# Rodar aplicação
dotnet run

# Ver logs RabbitMQ
docker logs rabbitmq

# Acessar Management UI
# http://localhost:15672 (guest/guest)

# Parar ambiente
.\stop-environment.ps1

# Testar API
# Use test-requests.http no VS Code
```

---

## 📱 Acesso Rápido

| Serviço                 | URL                    | Credenciais |
| ----------------------- | ---------------------- | ----------- |
| **API**                 | http://localhost:5000  | -           |
| **RabbitMQ Management** | http://localhost:15672 | guest/guest |
| **RabbitMQ AMQP**       | localhost:5672         | guest/guest |

---

## 🎨 Legenda de Emojis

| Emoji | Significado            |
| ----- | ---------------------- |
| ⭐    | Comece aqui            |
| 🚀    | Início rápido          |
| ✅    | Testes e verificação   |
| 🏗️    | Arquitetura            |
| 🔍    | Debug e monitoramento  |
| 📚    | Documentação detalhada |
| 📋    | Resumo/Lista           |
| 🧪    | Testes práticos        |
| 🎬    | Scripts/Automação      |
| 🛑    | Parar/Finalizar        |
| ❓    | Perguntas frequentes   |
| 💡    | Dicas importantes      |
| ⚠️    | Avisos                 |
| 🎯    | Objetivos              |

---

## 📞 Suporte

**Encontrou um problema?**

1. ✅ Consulte [`VERIFICATION_CHECKLIST.md`](VERIFICATION_CHECKLIST.md)
2. 🔍 Veja [`MONITORING_DEBUG.md`](MONITORING_DEBUG.md)
3. 📚 Leia [`README_RABBITMQ.md`](README_RABBITMQ.md)

**Ainda com dúvidas?**

-   Verifique os logs da aplicação
-   Verifique logs do Docker: `docker logs rabbitmq`
-   Acesse Management UI e veja status das filas

---

## 🎉 Pronto!

Agora você sabe navegar por toda a documentação. Escolha seu caminho e bom desenvolvimento! 🚀

**Sugestão**: Comece por [`QUICK_START.md`](QUICK_START.md) para ter o sistema rodando em minutos!
