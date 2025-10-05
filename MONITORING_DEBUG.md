# 🔍 Guia de Monitoramento e Debug - RabbitMQ

## 📊 Acessando o Management UI

URL: **http://localhost:15672**

-   Usuário: `guest`
-   Senha: `guest`

## 🎯 Principais Seções do Management UI

### 1. Overview

-   Visão geral das conexões, canais e mensagens
-   Taxa de mensagens por segundo
-   Status do servidor

### 2. Connections

-   Lista todas as conexões ativas
-   Mostra qual aplicação está conectada
-   Channels associados a cada conexão

### 3. Channels

-   Canais ativos
-   Taxa de confirmação e publicação
-   Consumer count

### 4. Exchanges

Procure por: **`pessoas_exchange`**

-   Tipo: `topic`
-   Durabilidade: `durable`
-   Veja as bindings (filas conectadas)

### 5. Queues

Procure por: **`pessoas_queue`**

-   Mensagens prontas (Ready)
-   Mensagens não confirmadas (Unacked)
-   Taxa de consumo

#### Visualizar Mensagens na Fila

1. Clique na fila `pessoas_queue`
2. Role até **"Get messages"**
3. Configure:
    - **Ack Mode**: `Ack message requeue false`
    - **Messages**: `10`
4. Clique em **"Get Message(s)"**

Exemplo de mensagem que você verá:

```json
{
    "eventType": "CREATE",
    "pessoa": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "nome": "João Silva",
        "email": "joao@email.com",
        "telefone": "(11) 98765-4321",
        "idade": 30,
        "endereco": "Rua Exemplo, 123"
    },
    "timestamp": "2025-10-04T15:30:00Z"
}
```

## 🐛 Comandos Docker para Debug

### Ver logs do RabbitMQ

```powershell
docker logs rabbitmq
```

### Ver logs em tempo real (follow)

```powershell
docker logs -f rabbitmq
```

### Ver últimas 100 linhas

```powershell
docker logs --tail 100 rabbitmq
```

### Entrar no container RabbitMQ

```powershell
docker exec -it rabbitmq bash
```

### Comandos dentro do container

#### Listar filas

```bash
rabbitmqctl list_queues name messages consumers
```

#### Listar exchanges

```bash
rabbitmqctl list_exchanges name type
```

#### Listar bindings

```bash
rabbitmqctl list_bindings
```

#### Status do cluster

```bash
rabbitmqctl cluster_status
```

#### Listar conexões

```bash
rabbitmqctl list_connections
```

#### Listar canais

```bash
rabbitmqctl list_channels
```

## 📈 Métricas Importantes

### Taxa de Mensagens

-   **Publish rate**: Mensagens sendo publicadas por segundo
-   **Consume rate**: Mensagens sendo consumidas por segundo
-   **Ack rate**: Mensagens confirmadas por segundo

### Saúde da Fila

-   **Ready**: Mensagens aguardando consumo
-   **Unacked**: Mensagens enviadas mas não confirmadas
-   **Total**: Total de mensagens

⚠️ Se **Unacked** está crescendo: o consumer pode estar lento ou travado

⚠️ Se **Ready** está crescendo: há mais mensagens sendo publicadas do que consumidas

## 🔧 Problemas Comuns e Soluções

### 1. Mensagens não estão sendo consumidas

**Sintomas:**

-   Ready count crescendo
-   Consumer count = 0

**Verificar:**

```powershell
# Ver se o consumer service está rodando
docker logs aula-sistemas-backend
```

**Solução:**

-   Verificar logs da aplicação
-   Garantir que `RabbitMQConsumerService` está registrado no `Program.cs`

### 2. Conexão recusada

**Erro:** `None of the specified endpoints were reachable`

**Verificar:**

```powershell
# RabbitMQ está rodando?
docker ps | Select-String rabbitmq

# Porta 5672 está aberta?
Test-NetConnection -ComputerName localhost -Port 5672
```

**Solução:**

```powershell
docker-compose up -d rabbitmq
# Aguarde 10-15 segundos antes de iniciar a aplicação
```

### 3. Mensagens vão para a fila mas não são processadas

**Verificar logs da aplicação:**

```
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      RabbitMQ Consumer iniciado e aguardando mensagens...
```

Se não vir esta mensagem, o consumer não inicializou.

**Debug:**

1. Verificar configurações em `appsettings.json`
2. Ver se há exceções nos logs
3. Verificar se há dead letter messages

### 4. Performance lenta

**Verificar:**

-   Consumer está processando 1 mensagem por vez? (QoS prefetchCount = 1)
-   Há erros no processamento?
-   Método `ProcessMessage` está muito lento?

**Otimizar:**

```csharp
// Aumentar prefetchCount se o processamento for rápido
_channel.BasicQos(
    prefetchSize: 0,
    prefetchCount: 10,  // Aumentar de 1 para 10
    global: false
);
```

## 📝 Logs Importantes da Aplicação

### Sucesso na conexão

```
info: aula_sistemas_backend.Services.RabbitMQService[0]
      RabbitMQ conectado com sucesso!
```

### Consumer iniciado

```
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      RabbitMQ Consumer iniciado e aguardando mensagens...
```

### Mensagem publicada

```
info: aula_sistemas_backend.Services.RabbitMQService[0]
      Mensagem publicada: pessoa.create
```

### Mensagem recebida

```
info: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      Mensagem recebida - Tipo: CREATE, Pessoa: João Silva, Timestamp: ...
```

### Erro ao publicar

```
fail: aula_sistemas_backend.Services.RabbitMQService[0]
      Erro ao publicar mensagem no RabbitMQ
      System.Exception: ...
```

### Erro ao processar

```
fail: aula_sistemas_backend.Services.RabbitMQConsumerService[0]
      Erro ao processar mensagem
      System.Exception: ...
```

## 🧪 Testando Manualmente

### Publicar mensagem via Management UI

1. Vá em **Queues** → **pessoas_queue**
2. Role até **"Publish message"**
3. Configure:
    - **Payload**: (cole o JSON abaixo)
    - **Delivery mode**: `2 - Persistent`
    - **Content type**: `application/json`

```json
{
    "eventType": "CREATE",
    "pessoa": {
        "id": "00000000-0000-0000-0000-000000000001",
        "nome": "Teste Manual",
        "email": "teste@email.com",
        "telefone": "(00) 00000-0000",
        "idade": 25,
        "endereco": "Endereço Teste"
    },
    "timestamp": "2025-10-04T12:00:00Z"
}
```

4. Clique em **"Publish message"**
5. Verifique os logs da aplicação para ver o processamento

## 📊 Monitoramento Avançado

### Habilitar Prometheus (Opcional)

No `docker-compose.yml`, adicione:

```yaml
rabbitmq:
    image: rabbitmq:4.1.4-management
    environment:
        - RABBITMQ_PROMETHEUS_PLUGIN=enabled
    ports:
        - "15692:15692" # Prometheus metrics
```

Acesse métricas em: http://localhost:15692/metrics

### Exportar definições do RabbitMQ

Para backup ou migração:

```powershell
# Baixar definições (exchanges, queues, bindings)
curl http://localhost:15672/api/definitions -u guest:guest -o rabbitmq-definitions.json
```

### Importar definições

```powershell
curl -X POST -u guest:guest -H "Content-Type: application/json" `
  -d "@rabbitmq-definitions.json" `
  http://localhost:15672/api/definitions
```

## 🚨 Alertas e Limites

### Configurar Limites de Memória

No `docker-compose.yml`:

```yaml
rabbitmq:
    environment:
        - RABBITMQ_VM_MEMORY_HIGH_WATERMARK=1GB
```

### Configurar Disk Free Limit

```yaml
rabbitmq:
    environment:
        - RABBITMQ_DISK_FREE_LIMIT=2GB
```

## 💡 Dicas de Produção

1. **Sempre usar confirmações** (acknowledgements)
2. **Implementar Dead Letter Exchange** para mensagens com erro
3. **Monitorar taxa de mensagens** para dimensionar consumers
4. **Usar TTL** (Time To Live) para mensagens
5. **Implementar circuit breaker** para falhas de conexão
6. **Log estruturado** com correlation IDs
7. **Health checks** da aplicação devem incluir RabbitMQ
8. **Backup** das definições regularmente

## 📚 Recursos Adicionais

-   [RabbitMQ Management HTTP API](https://www.rabbitmq.com/management.html#http-api)
-   [RabbitMQ Monitoring Guide](https://www.rabbitmq.com/monitoring.html)
-   [Production Checklist](https://www.rabbitmq.com/production-checklist.html)
