# Sistema Backend com RabbitMQ

Este projeto foi adaptado para usar RabbitMQ como sistema de mensageria, permitindo a publicação e consumo de eventos relacionados à entidade Pessoa.

## 🐰 RabbitMQ

O RabbitMQ está configurado na versão `4.1.4-management` e funciona como um broker de mensagens para processar eventos assíncronos.

### Configuração

As configurações do RabbitMQ estão no arquivo `appsettings.json`:

```json
{
    "RabbitMQ": {
        "HostName": "localhost",
        "Port": 5672,
        "UserName": "guest",
        "Password": "guest",
        "VirtualHost": "/",
        "QueueName": "pessoas_queue",
        "ExchangeName": "pessoas_exchange",
        "RoutingKey": "pessoa"
    }
}
```

### Eventos Publicados

O sistema publica eventos para as seguintes operações:

-   **CREATE** (`pessoa.create`): Quando uma nova pessoa é criada
-   **UPDATE** (`pessoa.update`): Quando uma pessoa é atualizada
-   **DELETE** (`pessoa.delete`): Quando uma pessoa é deletada

## 🚀 Como Executar

### Pré-requisitos

-   .NET 9.0 SDK
-   Docker e Docker Compose

### Passos

1. **Restaurar as dependências do projeto:**

```powershell
dotnet restore
```

2. **Subir o RabbitMQ via Docker Compose:**

```powershell
docker-compose up -d rabbitmq
```

3. **Verificar se o RabbitMQ está rodando:**

Acesse a interface de gerenciamento em: [http://localhost:15672](http://localhost:15672)

-   Usuário: `guest`
-   Senha: `guest`

4. **Executar a aplicação:**

```powershell
dotnet run
```

Ou via Docker Compose (completo):

```powershell
docker-compose up --build
```

## 📡 Endpoints da API

### Listar todas as pessoas

```http
GET http://localhost:5000/api/v1/pessoas
```

### Buscar pessoa por ID

```http
GET http://localhost:5000/api/v1/pessoas/{id}
```

### Criar nova pessoa

```http
POST http://localhost:5000/api/v1/pessoas
Content-Type: application/json

{
  "nome": "João Silva",
  "email": "joao@email.com",
  "telefone": "(11) 98765-4321",
  "idade": 30,
  "endereco": "Rua Exemplo, 123"
}
```

### Atualizar pessoa

```http
PUT http://localhost:5000/api/v1/pessoas/{id}
Content-Type: application/json

{
  "nome": "João Silva Santos",
  "email": "joao.santos@email.com",
  "telefone": "(11) 98765-4321",
  "idade": 31,
  "endereco": "Rua Nova, 456"
}
```

### Deletar pessoa

```http
DELETE http://localhost:5000/api/v1/pessoas/{id}
```

## 🔄 Fluxo de Mensageria

1. **Controller recebe requisição HTTP**
2. **Processa a operação (CREATE/UPDATE/DELETE)**
3. **Armazena/Atualiza no Redis para cache**
4. **Publica evento no RabbitMQ** através do `RabbitMQService`
5. **RabbitMQConsumerService consome a mensagem** da fila
6. **Processa o evento** (pode ser integrado com outros serviços)

## 🏗️ Arquitetura

```
┌─────────────────┐
│   Cliente HTTP  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│ PessoaController│─────▶│ Redis Cache  │
└────────┬────────┘      └──────────────┘
         │
         │ publica evento
         ▼
┌─────────────────┐      ┌──────────────────────┐
│ RabbitMQService │─────▶│ RabbitMQ (Exchange)  │
└─────────────────┘      └──────────┬───────────┘
                                    │ binding
                         ┌──────────▼───────────┐
                         │  Fila: pessoas_queue │
                         └──────────┬───────────┘
                                    │
                         ┌──────────▼──────────────────┐
                         │ RabbitMQConsumerService     │
                         │ (Background Service)        │
                         └─────────────────────────────┘
```

## 📦 Estrutura do Projeto

```
.
├── Controllers/
│   └── PessoaController.cs    # API REST
├── Models/
│   ├── Pessoa.cs              # Entidade Pessoa
│   └── PessoaEvent.cs         # Evento de mensageria
├── Services/
│   ├── RabbitMQService.cs            # Publicador de mensagens
│   └── RabbitMQConsumerService.cs    # Consumidor de mensagens
├── Program.cs                 # Configuração da aplicação
├── docker-compose.yml         # Orquestração Docker
└── appsettings.json          # Configurações
```

## 🔍 Monitoramento

### RabbitMQ Management UI

Acesse [http://localhost:15672](http://localhost:15672) para:

-   Visualizar filas e exchanges
-   Monitorar mensagens
-   Ver taxas de publicação e consumo
-   Gerenciar conexões e canais

### Logs da Aplicação

O sistema registra logs para todas as operações de mensageria:

-   Publicação de eventos
-   Consumo de mensagens
-   Erros de processamento

## 🛠️ Desenvolvimento

### Adicionar novo tipo de evento

1. Defina o novo tipo no enum (ex: "APPROVE", "REJECT")
2. Publique o evento no controller correspondente
3. Adicione o case no `ProcessMessage` do `RabbitMQConsumerService`

### Customizar processamento de mensagens

Edite o método `ProcessMessage` em `RabbitMQConsumerService.cs` para adicionar lógica customizada:

```csharp
private async Task ProcessMessage(PessoaEvent pessoaEvent)
{
    switch (pessoaEvent.EventType)
    {
        case "CREATE":
            // Sua lógica aqui (ex: enviar email, notificar outros serviços)
            await EnviarEmailBoasVindas(pessoaEvent.Pessoa);
            break;
        // ...
    }
}
```

## 📝 Notas

-   O sistema usa exchange do tipo **Topic** para permitir roteamento flexível
-   As mensagens são persistentes (`durable: true`)
-   O QoS está configurado para processar 1 mensagem por vez
-   Em caso de erro, a mensagem não é reprocessada (pode ser configurado Dead Letter Queue)
-   O Redis continua sendo usado para cache das consultas

## 🔐 Segurança

Para produção, altere as credenciais padrão do RabbitMQ:

```yaml
environment:
    - RABBITMQ_DEFAULT_USER=seu_usuario
    - RABBITMQ_DEFAULT_PASS=sua_senha_segura
```

E atualize o `appsettings.json` correspondentemente.
