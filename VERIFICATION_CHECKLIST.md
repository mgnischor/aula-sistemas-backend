# ✅ Checklist de Verificação - Sistema RabbitMQ

## 📝 Pré-requisitos

-   [ ] .NET 9.0 SDK instalado
-   [ ] Docker Desktop instalado e rodando
-   [ ] PowerShell disponível

## 🚀 Teste Passo a Passo

### 1. Verificar Docker

```powershell
docker --version
docker ps
```

**Esperado**: Versão do Docker exibida e nenhum erro

---

### 2. Iniciar RabbitMQ

```powershell
cd d:\GITHUB\aula-sistemas-backend
docker-compose up -d rabbitmq
```

**Esperado**:

```
✔ Container rabbitmq  Started
```

**Aguarde 15 segundos** para o RabbitMQ inicializar completamente.

---

### 3. Verificar RabbitMQ está rodando

```powershell
docker ps | Select-String rabbitmq
```

**Esperado**: Linha mostrando container rabbitmq com status "Up" e "healthy"

---

### 4. Acessar Management UI

Abra no navegador: **http://localhost:15672**

-   [ ] Página de login carregou
-   [ ] Login com `guest` / `guest` funcionou
-   [ ] Dashboard apareceu

---

### 5. Restaurar e Compilar

```powershell
dotnet restore
dotnet build
```

**Esperado**:

```
Restauração concluída (0,Xs)
Construir êxito em X,Xs
```

---

### 6. Executar a Aplicação

```powershell
dotnet run
```

**Logs esperados**:

```
info: aula_sistemas_backend.Services.RabbitMQService[0]
      RabbitMQ conectado com sucesso!
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      RabbitMQ Consumer iniciado e aguardando mensagens...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
```

-   [ ] Viu "RabbitMQ conectado com sucesso!"
-   [ ] Viu "RabbitMQ Consumer iniciado e aguardando mensagens..."
-   [ ] Aplicação rodando em http://localhost:5000

---

### 7. Verificar Exchange e Queue no RabbitMQ UI

No Management UI (http://localhost:15672):

#### Exchanges

1. Clique em **"Exchanges"**
2. Procure por **`pessoas_exchange`**

-   [ ] Exchange existe
-   [ ] Type: `topic`
-   [ ] Durability: `durable`

#### Queues

1. Clique em **"Queues and Streams"**
2. Procure por **`pessoas_queue`**

-   [ ] Queue existe
-   [ ] Durability: `durable`
-   [ ] 1 consumer conectado
-   [ ] Ready: 0 mensagens
-   [ ] Unacked: 0 mensagens

---

### 8. Testar CREATE (Criar Pessoa)

**Abra novo terminal PowerShell** (deixe aplicação rodando no outro):

```powershell
$body = @{
    nome = "João Silva"
    email = "joao@email.com"
    telefone = "(11) 98765-4321"
    idade = 30
    endereco = "Rua Exemplo, 123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/pessoas" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

$response
$pessoaId = $response.id
Write-Host "ID da pessoa criada: $pessoaId" -ForegroundColor Green
```

**Verificações**:

1. **Resposta da API**:

    - [ ] Status 201 Created
    - [ ] Resposta contém ID, nome, email, etc.

2. **Logs da aplicação** (terminal onde rodou `dotnet run`):

    - [ ] "Evento de criação publicado para pessoa: {Id}"
    - [ ] "Mensagem publicada: pessoa.create"
    - [ ] "Mensagem recebida - Tipo: CREATE, Pessoa: João Silva"
    - [ ] "Processando criação da pessoa: João Silva"

3. **RabbitMQ Management UI**:
    - Vá em Queues → pessoas_queue
    - [ ] Veja na seção "Message rates" que houve atividade
    - [ ] "Publish" e "Consumer ack" com valores > 0

---

### 9. Testar GET (Listar Pessoas)

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/pessoas" -Method GET
```

**Esperado**:

-   [ ] Array com a pessoa criada
-   [ ] Dados corretos (nome, email, etc.)

---

### 10. Testar UPDATE (Atualizar Pessoa)

```powershell
# Use o ID da pessoa criada anteriormente
$body = @{
    nome = "João Silva Santos"
    email = "joao.santos@email.com"
    telefone = "(11) 91234-5678"
    idade = 31
    endereco = "Av. Paulista, 1000"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/v1/pessoas/$pessoaId" `
    -Method PUT `
    -ContentType "application/json" `
    -Body $body
```

**Verificações**:

-   [ ] Status 204 No Content
-   [ ] Logs mostram "pessoa.update"
-   [ ] Consumer processou UPDATE

---

### 11. Testar DELETE (Deletar Pessoa)

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/v1/pessoas/$pessoaId" `
    -Method DELETE
```

**Verificações**:

-   [ ] Status 204 No Content
-   [ ] Logs mostram "pessoa.delete"
-   [ ] Consumer processou DELETE

---

### 12. Verificar Estatísticas no RabbitMQ

No Management UI → Queues → pessoas_queue:

-   [ ] Total de mensagens publicadas ≈ 3 (CREATE, UPDATE, DELETE)
-   [ ] Total de mensagens consumidas ≈ 3
-   [ ] Ready: 0 (nenhuma mensagem pendente)
-   [ ] Unacked: 0 (nenhuma mensagem não confirmada)

---

### 13. Publicar Mensagem Manual no RabbitMQ

Para testar o consumer diretamente:

1. No Management UI → Queues → pessoas_queue
2. Role até **"Publish message"**
3. Cole este JSON em **Payload**:

```json
{
    "eventType": "CREATE",
    "pessoa": {
        "id": "00000000-0000-0000-0000-000000000001",
        "nome": "Teste Manual",
        "email": "teste@email.com",
        "telefone": "(00) 00000-0000",
        "idade": 99,
        "endereco": "Endereço Teste"
    },
    "timestamp": "2025-10-04T12:00:00Z"
}
```

4. Configure:
    - **Delivery mode**: `2 - Persistent`
    - **Content type**: `application/json`
5. Clique **"Publish message"**

**Verificações**:

-   [ ] Mensagem foi publicada (aparece confirmação)
-   [ ] Logs da aplicação mostram processamento
-   [ ] "Processando criação da pessoa: Teste Manual"

---

## 🎉 Teste Completo com Script

Use o script automático:

```powershell
.\start-environment.ps1
```

**Esperado**:

```
🚀 Iniciando ambiente de desenvolvimento...
📦 Verificando Docker...
✅ Docker está rodando
🐰 Iniciando RabbitMQ...
⏳ Aguardando RabbitMQ inicializar (15 segundos)...
🔍 Verificando saúde do RabbitMQ...
✅ RabbitMQ está saudável e pronto!
📦 Restaurando pacotes NuGet...
🔨 Compilando projeto...
✅ Ambiente configurado com sucesso!
```

---

## 🔍 Troubleshooting

### Problema: RabbitMQ não inicia

```powershell
docker logs rabbitmq
```

Verifique erros nos logs.

**Solução**:

```powershell
docker-compose down
docker-compose up -d rabbitmq
```

---

### Problema: Aplicação não conecta ao RabbitMQ

**Erro**: `None of the specified endpoints were reachable`

**Solução**:

1. Aguarde mais tempo (RabbitMQ pode levar até 30s)
2. Verifique se porta 5672 está livre:
    ```powershell
    Test-NetConnection -ComputerName localhost -Port 5672
    ```

---

### Problema: Consumer não processa mensagens

**Verificar**:

```powershell
# No Management UI → Connections
# Deve ter 1 conexão do consumer
```

**Logs esperados**:

```
RabbitMQ Consumer iniciado e aguardando mensagens...
```

Se não aparecer, reinicie a aplicação.

---

### Problema: Mensagens ficam em Ready (não consumidas)

**Causa**: Consumer travou ou não está registrado

**Solução**:

1. Reinicie a aplicação
2. Verifique em Program.cs:
    ```csharp
    builder.Services.AddHostedService<RabbitMQConsumerService>();
    ```

---

## ✅ Checklist Final

-   [ ] Docker está rodando
-   [ ] RabbitMQ container está healthy
-   [ ] Management UI acessível (localhost:15672)
-   [ ] Aplicação compila sem erros
-   [ ] Aplicação conecta ao RabbitMQ
-   [ ] Consumer está registrado e ativo
-   [ ] Exchange `pessoas_exchange` existe
-   [ ] Queue `pessoas_queue` existe com 1 consumer
-   [ ] CREATE publica e consome mensagem
-   [ ] UPDATE publica e consome mensagem
-   [ ] DELETE publica e consome mensagem
-   [ ] Todas as mensagens são confirmadas (ACK)
-   [ ] Logs estruturados aparecem corretamente

---

## 🎯 Status Esperado

Se todos os itens acima estão ✅:

**🎉 Sistema RabbitMQ totalmente funcional!**

Você pode agora:

-   Adicionar novos consumers
-   Implementar lógica de negócio no ProcessMessage
-   Escalar horizontalmente
-   Adicionar Dead Letter Queue
-   Implementar retry policies
-   Integrar com outros sistemas

---

## 📚 Próximos Passos

1. Ler `README_RABBITMQ.md` para entender a arquitetura completa
2. Ler `MONITORING_DEBUG.md` para monitoramento avançado
3. Ler `ARCHITECTURE.md` para diagramas detalhados
4. Experimentar com `test-requests.http`
5. Implementar casos de uso específicos (email, notificações, etc.)

---

## 💾 Parar o Ambiente

```powershell
# Parar aplicação: Ctrl+C no terminal

# Parar containers
.\stop-environment.ps1

# Ou manualmente
docker-compose down

# Limpar tudo (incluindo dados)
docker-compose down -v
```

---

**Data de criação**: 2025-10-04  
**Versão RabbitMQ**: 4.1.4-management  
**Versão .NET**: 9.0
