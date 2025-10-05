# 🏗️ Arquitetura e Diagramas do Sistema

## 📐 Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                         Cliente HTTP                            │
│                    (Browser, Postman, etc)                      │
└────────────────┬────────────────────────────────────────────────┘
                 │
                 │ HTTP REST
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ASP.NET Core Web API                         │
│                   (aula-sistemas-backend)                       │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              PessoaController                             │ │
│  │  • GET    /api/v1/pessoas                                 │ │
│  │  • GET    /api/v1/pessoas/{id}                            │ │
│  │  • POST   /api/v1/pessoas                                 │ │
│  │  • PUT    /api/v1/pessoas/{id}                            │ │
│  │  • DELETE /api/v1/pessoas/{id}                            │ │
│  └────┬──────────────────────────────────────────┬───────────┘ │
│       │                                           │             │
│       ▼                                           ▼             │
│  ┌─────────┐                              ┌──────────────┐     │
│  │  Redis  │◄────Cache Read/Write─────────│ RabbitMQ     │     │
│  │ Service │                              │ Service      │     │
│  └────┬────┘                              └──────┬───────┘     │
│       │                                           │             │
└───────┼───────────────────────────────────────────┼─────────────┘
        │                                           │
        │                                           │ Publish Event
        ▼                                           ▼
┌────────────────┐                    ┌──────────────────────────┐
│     Redis      │                    │       RabbitMQ           │
│   localhost    │                    │   localhost:5672         │
│     :6379      │                    │   Management: :15672     │
│                │                    │                          │
│ • Pessoa Cache │                    │  ┌────────────────────┐  │
│ • List Cache   │                    │  │ pessoas_exchange   │  │
└────────────────┘                    │  │  (Type: Topic)     │  │
                                      │  └─────────┬──────────┘  │
                                      │            │ binding     │
                                      │            │ pessoa.#    │
                                      │  ┌─────────▼──────────┐  │
                                      │  │  pessoas_queue     │  │
                                      │  │  (Durable)         │  │
                                      │  └─────────┬──────────┘  │
                                      └────────────┼─────────────┘
                                                   │
                                                   │ Consume
                                                   ▼
                                      ┌──────────────────────────┐
                                      │ RabbitMQConsumerService  │
                                      │   (Background Service)   │
                                      │                          │
                                      │ • Process CREATE events  │
                                      │ • Process UPDATE events  │
                                      │ • Process DELETE events  │
                                      └──────────────────────────┘
```

## 🔄 Fluxo de Criação de Pessoa (POST)

```
Cliente                Controller           Redis        RabbitMQ         Consumer
  │                       │                   │             │               │
  ├─POST /pessoas────────►│                   │             │               │
  │                       │                   │             │               │
  │                       ├─Create Pessoa     │             │               │
  │                       ├─Add to List       │             │               │
  │                       │                   │             │               │
  │                       ├─Save Cache───────►│             │               │
  │                       │◄──────────────────┤             │               │
  │                       │                   │             │               │
  │                       ├─Invalidate List──►│             │               │
  │                       │◄──────────────────┤             │               │
  │                       │                   │             │               │
  │                       ├─Create Event      │             │               │
  │                       │   {type: CREATE}  │             │               │
  │                       │                   │             │               │
  │                       ├─Publish───────────┼────────────►│               │
  │                       │   pessoa.create   │             │               │
  │                       │                   │             │               │
  │◄─201 Created──────────┤                   │             ├──Route────────►│
  │   {pessoa}            │                   │             │  pessoa.#     │
  │                       │                   │             │               │
  │                       │                   │             │               ├─Receive
  │                       │                   │             │               │  Message
  │                       │                   │             │               │
  │                       │                   │             │               ├─Process
  │                       │                   │             │               │  CREATE
  │                       │                   │             │               │
  │                       │                   │             │               ├─ACK
  │                       │                   │             │◄──────────────┤
  │                       │                   │             │               │
```

## 🔄 Fluxo de Atualização (PUT)

```
Cliente                Controller           Redis        RabbitMQ         Consumer
  │                       │                   │             │               │
  ├─PUT /pessoas/{id}────►│                   │             │               │
  │                       │                   │             │               │
  │                       ├─Find Pessoa       │             │               │
  │                       ├─Update Fields     │             │               │
  │                       │                   │             │               │
  │                       ├─Update Cache─────►│             │               │
  │                       ├─Invalidate List──►│             │               │
  │                       │                   │             │               │
  │                       ├─Publish UPDATE───┼────────────►│──────────────►│
  │                       │   pessoa.update   │             │               │
  │◄─204 No Content───────┤                   │             │               │
  │                       │                   │             │               │
```

## 🔄 Fluxo de Deleção (DELETE)

```
Cliente                Controller           Redis        RabbitMQ         Consumer
  │                       │                   │             │               │
  ├─DELETE /pessoas/{id}─►│                   │             │               │
  │                       │                   │             │               │
  │                       ├─Find Pessoa       │             │               │
  │                       ├─Remove from List  │             │               │
  │                       │                   │             │               │
  │                       ├─Delete Cache─────►│             │               │
  │                       ├─Invalidate List──►│             │               │
  │                       │                   │             │               │
  │                       ├─Publish DELETE───┼────────────►│──────────────►│
  │                       │   pessoa.delete   │             │               │
  │◄─204 No Content───────┤                   │             │               │
  │                       │                   │             │               │
```

## 🔄 Fluxo de Consulta (GET)

### GET All com Cache Hit

```
Cliente                Controller           Redis        RabbitMQ
  │                       │                   │             │
  ├─GET /pessoas─────────►│                   │             │
  │                       │                   │             │
  │                       ├─Check Cache──────►│             │
  │                       │◄─Return List──────┤             │
  │◄─200 OK───────────────┤                   │             │
  │   [{pessoas}]         │                   │             │
```

### GET All com Cache Miss

```
Cliente                Controller           Redis        RabbitMQ
  │                       │                   │             │
  ├─GET /pessoas─────────►│                   │             │
  │                       │                   │             │
  │                       ├─Check Cache──────►│             │
  │                       │◄─Empty────────────┤             │
  │                       │                   │             │
  │                       ├─Get from Memory   │             │
  │                       │                   │             │
  │                       ├─Save Cache───────►│             │
  │◄─200 OK───────────────┤                   │             │
  │   [{pessoas}]         │                   │             │
```

## 📦 Estrutura de Pastas

```
aula-sistemas-backend/
│
├── Controllers/
│   └── PessoaController.cs        # API REST endpoints
│
├── Models/
│   ├── Pessoa.cs                  # Entidade principal
│   └── PessoaEvent.cs             # Evento de mensageria
│
├── Services/
│   ├── RabbitMQService.cs         # Publisher (envia mensagens)
│   └── RabbitMQConsumerService.cs # Consumer (recebe mensagens)
│
├── Properties/
│   └── launchSettings.json        # Configurações de execução
│
├── terraform/                     # Infraestrutura como código
│
├── appsettings.json              # Configurações de produção
├── appsettings.Development.json  # Configurações de desenvolvimento
├── docker-compose.yml            # Orquestração de containers
├── Dockerfile                    # Imagem da aplicação
├── Program.cs                    # Startup e DI
│
├── README_RABBITMQ.md           # Documentação completa
├── QUICK_START.md               # Guia rápido
├── MONITORING_DEBUG.md          # Guia de monitoramento
├── ARCHITECTURE.md              # Este arquivo
├── test-requests.http           # Requisições de teste
├── start-environment.ps1        # Script de inicialização
└── stop-environment.ps1         # Script de parada
```

## 🔌 Modelo de Dados

### Pessoa

```csharp
public class Pessoa
{
    public Guid Id { get; set; }          // Identificador único
    public string Nome { get; set; }      // Nome completo
    public string Email { get; set; }     // Email (único)
    public string Telefone { get; set; }  // Telefone
    public int? Idade { get; set; }       // Idade (opcional)
    public string Endereco { get; set; }  // Endereço completo
}
```

### PessoaEvent

```csharp
public class PessoaEvent
{
    public string EventType { get; set; }   // CREATE | UPDATE | DELETE
    public Pessoa? Pessoa { get; set; }     // Dados da pessoa
    public DateTime Timestamp { get; set; } // Momento do evento
}
```

## 🎯 Padrões de Routing

### Exchange: pessoas_exchange (Type: Topic)

```
Routing Key          │ Descrição
─────────────────────┼──────────────────────────────
pessoa.create        │ Criação de pessoa
pessoa.update        │ Atualização de pessoa
pessoa.delete        │ Deleção de pessoa
pessoa.#             │ Todos os eventos (binding)
```

### Exemplo de Binding Patterns

```
Pattern      │ Matches
─────────────┼────────────────────────────────────
pessoa.*     │ pessoa.create, pessoa.update, pessoa.delete
pessoa.#     │ pessoa, pessoa.create, pessoa.create.validated
#.create     │ pessoa.create, user.create, etc.
*.create     │ pessoa.create, user.create (apenas 1 nível)
```

## 🔐 Camadas de Segurança (Futuro)

```
┌────────────────────────────────────────┐
│         API Gateway / Load Balancer    │
│              (HTTPS/TLS)               │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│      Authentication / Authorization     │
│       (JWT, OAuth2, API Keys)          │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│          Rate Limiting                 │
│          (Throttling)                  │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│         Controllers Layer              │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│         Services Layer                 │
└────────────────────────────────────────┘
```

## 📊 Estratégia de Cache (Redis)

```
Cache Key Format          │ TTL      │ Descrição
──────────────────────────┼──────────┼─────────────────────
pessoa:{guid}             │ 5 min    │ Dados de pessoa individual
pessoas:all               │ 5 min    │ Lista completa de pessoas
```

### Invalidação de Cache

-   **CREATE**: Invalida `pessoas:all`
-   **UPDATE**: Invalida `pessoa:{id}` e `pessoas:all`
-   **DELETE**: Invalida `pessoa:{id}` e `pessoas:all`

## 🚀 Escalabilidade

### Horizontal Scaling

```
                           ┌─────────────┐
                           │ Load Balancer│
                           └──────┬──────┘
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
              ┌─────▼───┐   ┌─────▼───┐   ┌────▼────┐
              │ App #1  │   │ App #2  │   │ App #3  │
              └─────┬───┘   └─────┬───┘   └────┬────┘
                    │             │             │
                    └─────────────┼─────────────┘
                                  │
                          ┌───────▼────────┐
                          │   RabbitMQ     │
                          │   (Clustered)  │
                          └────────────────┘
```

### Consumer Scaling

-   Múltiplas instâncias da aplicação = múltiplos consumers
-   RabbitMQ distribui mensagens entre consumers (round-robin)
-   QoS garante processamento controlado

## 🔄 Resiliência e Recuperação

### Circuit Breaker Pattern (Futuro)

```
Normal State → Failure Detection → Open (fail fast)
     ↑                                    ↓
     └──────── Close ←── Half-Open ←──────┘
```

### Retry Policy (Futuro)

```
Attempt 1 → Fail → Wait 1s → Attempt 2 → Fail → Wait 2s
                                 ↓
                            Attempt 3 → Fail → Wait 4s
                                 ↓
                      Attempt 4 → Fail → Dead Letter Queue
```

## 📈 Métricas e Observabilidade (Futuro)

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ Application │────►│   Prometheus │────►│   Grafana    │
│    Logs     │     │   (Metrics)  │     │ (Dashboard)  │
└─────────────┘     └──────────────┘     └──────────────┘
      │
      │
      ▼
┌─────────────┐     ┌──────────────┐
│   Serilog   │────►│ Elasticsearch│
│  (Logging)  │     │  + Kibana    │
└─────────────┘     └──────────────┘
```

## 🎯 Casos de Uso

### 1. Sistema de Notificações

-   Consumer envia email quando pessoa é criada
-   Consumer envia SMS quando dados críticos são alterados

### 2. Auditoria

-   Consumer registra todas as mudanças em banco de auditoria
-   Mantém histórico completo de alterações

### 3. Integração com Outros Sistemas

-   Consumer sincroniza dados com sistema CRM
-   Consumer atualiza data warehouse

### 4. Processamento Assíncrono

-   Validações complexas em background
-   Enriquecimento de dados via APIs externas

## 📚 Referências

-   [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)
-   [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
-   [Microservices Patterns](https://microservices.io/patterns/index.html)
-   [ASP.NET Core Best Practices](https://docs.microsoft.com/aspnet/core/fundamentals/)
