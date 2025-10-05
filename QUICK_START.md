# 🚀 Guia Rápido - Iniciando o Sistema

## Passo 1: Subir o RabbitMQ

Apenas o RabbitMQ:

```powershell
docker-compose up -d rabbitmq
```

Ou todo o ambiente (RabbitMQ + Aplicação):

```powershell
docker-compose up --build
```

## Passo 2: Acessar o Management UI do RabbitMQ

Abra o navegador em: **http://localhost:15672**

-   Usuário: `guest`
-   Senha: `guest`

## Passo 3: Executar a Aplicação (se não usou docker-compose completo)

```powershell
dotnet run
```

A aplicação estará disponível em: **http://localhost:5000**

## Passo 4: Testar a API

### Opção 1: Usar o arquivo test-requests.http

Abra o arquivo `test-requests.http` no VS Code com a extensão REST Client instalada e execute as requisições.

### Opção 2: Usar cURL

#### Criar uma pessoa

```powershell
curl -X POST http://localhost:5000/api/v1/pessoas `
  -H "Content-Type: application/json" `
  -d '{\"nome\":\"João Silva\",\"email\":\"joao@email.com\",\"telefone\":\"(11) 98765-4321\",\"idade\":30,\"endereco\":\"Rua Exemplo, 123\"}'
```

#### Listar todas as pessoas

```powershell
curl http://localhost:5000/api/v1/pessoas
```

#### Buscar pessoa por ID (substitua {id})

```powershell
curl http://localhost:5000/api/v1/pessoas/{id}
```

#### Atualizar pessoa (substitua {id})

```powershell
curl -X PUT http://localhost:5000/api/v1/pessoas/{id} `
  -H "Content-Type: application/json" `
  -d '{\"nome\":\"João Silva Santos\",\"email\":\"joao.santos@email.com\",\"telefone\":\"(11) 98765-4321\",\"idade\":31,\"endereco\":\"Rua Nova, 456\"}'
```

#### Deletar pessoa (substitua {id})

```powershell
curl -X DELETE http://localhost:5000/api/v1/pessoas/{id}
```

## Passo 5: Monitorar Mensagens no RabbitMQ

1. Acesse o Management UI: http://localhost:15672
2. Vá em **Queues and Streams**
3. Clique em `pessoas_queue`
4. Veja as mensagens sendo processadas

### Visualizar Mensagens

Na página da fila, vá em **Get messages** e clique em **Get Message(s)** para ver o conteúdo.

## Passo 6: Verificar Logs

Os logs da aplicação mostrarão:

```
info: aula_sistemas_backend.Services.RabbitMQService[0]
      RabbitMQ conectado com sucesso!
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      RabbitMQ Consumer iniciado e aguardando mensagens...
info: aula_sistemas_backend.Controllers.PessoaController[0]
      Evento de criação publicado para pessoa: {Id}
info: aula_sistemas_backend.Services.RabbitMQService[0]
      Mensagem publicada: pessoa.create
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      Mensagem recebida - Tipo: CREATE, Pessoa: João Silva, Timestamp: ...
```

## 🔍 Troubleshooting

### RabbitMQ não conecta

Verifique se o container está rodando:

```powershell
docker ps | Select-String rabbitmq
```

Se não estiver, suba novamente:

```powershell
docker-compose up -d rabbitmq
```

### Aplicação não encontra o RabbitMQ

Aguarde alguns segundos após subir o RabbitMQ antes de iniciar a aplicação. O RabbitMQ leva um tempo para inicializar completamente.

### Verificar logs do RabbitMQ

```powershell
docker logs rabbitmq
```

### Parar todos os containers

```powershell
docker-compose down
```

### Remover volumes (limpar dados)

```powershell
docker-compose down -v
```

## 📊 Estrutura dos Eventos

Cada evento publicado tem a seguinte estrutura:

```json
{
    "eventType": "CREATE|UPDATE|DELETE",
    "pessoa": {
        "id": "guid",
        "nome": "string",
        "email": "string",
        "telefone": "string",
        "idade": 0,
        "endereco": "string"
    },
    "timestamp": "2025-10-04T12:00:00Z"
}
```

## 🎯 Próximos Passos

-   [ ] Implementar Dead Letter Queue para mensagens com erro
-   [ ] Adicionar retry policy
-   [ ] Implementar confirmação de publicação (publisher confirms)
-   [ ] Adicionar métricas e health checks
-   [ ] Implementar padrão SAGA para transações distribuídas
-   [ ] Adicionar autenticação e autorização
-   [ ] Criar testes de integração

## 📚 Recursos Adicionais

-   [Documentação RabbitMQ](https://www.rabbitmq.com/documentation.html)
-   [RabbitMQ.Client .NET Documentation](https://www.rabbitmq.com/dotnet-api-guide.html)
-   [Patterns for Messaging](https://www.enterpriseintegrationpatterns.com/)
