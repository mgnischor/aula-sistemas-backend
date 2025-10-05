using System.Text;
using System.Text.Json;
using aula_sistemas_backend.Models;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace aula_sistemas_backend.Services
{
    public class RabbitMQConsumerService : BackgroundService
    {
        private readonly ILogger<RabbitMQConsumerService> _logger;
        private readonly IConfiguration _configuration;
        private IConnection? _connection;
        private IModel? _channel;

        public RabbitMQConsumerService(
            ILogger<RabbitMQConsumerService> logger,
            IConfiguration configuration
        )
        {
            _logger = logger;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await Task.Delay(5000, stoppingToken); // Aguarda 5 segundos para garantir que o RabbitMQ está pronto

            try
            {
                var factory = new ConnectionFactory
                {
                    HostName = _configuration["RabbitMQ:HostName"],
                    Port = int.Parse(_configuration["RabbitMQ:Port"] ?? "5672"),
                    UserName = _configuration["RabbitMQ:UserName"],
                    Password = _configuration["RabbitMQ:Password"],
                    VirtualHost = _configuration["RabbitMQ:VirtualHost"],
                    DispatchConsumersAsync = true,
                };

                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();

                var exchangeName = _configuration["RabbitMQ:ExchangeName"] ?? "pessoas_exchange";
                var queueName = _configuration["RabbitMQ:QueueName"] ?? "pessoas_queue";
                var routingKey = _configuration["RabbitMQ:RoutingKey"] ?? "pessoa";

                // Declara o exchange
                _channel.ExchangeDeclare(
                    exchange: exchangeName,
                    type: ExchangeType.Topic,
                    durable: true,
                    autoDelete: false
                );

                // Declara a fila
                _channel.QueueDeclare(
                    queue: queueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null
                );

                // Faz o binding da fila ao exchange
                _channel.QueueBind(
                    queue: queueName,
                    exchange: exchangeName,
                    routingKey: $"{routingKey}.#"
                );

                // Configura QoS
                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

                _logger.LogInformation("RabbitMQ Consumer iniciado e aguardando mensagens...");

                var consumer = new AsyncEventingBasicConsumer(_channel);
                consumer.Received += async (model, ea) =>
                {
                    try
                    {
                        var body = ea.Body.ToArray();
                        var message = Encoding.UTF8.GetString(body);
                        var pessoaEvent = JsonSerializer.Deserialize<PessoaEvent>(message);

                        if (pessoaEvent != null)
                        {
                            _logger.LogInformation(
                                "Mensagem recebida - Tipo: {EventType}, Pessoa: {Nome}, Timestamp: {Timestamp}",
                                pessoaEvent.EventType,
                                pessoaEvent.Pessoa?.Nome,
                                pessoaEvent.Timestamp
                            );

                            // Aqui você pode processar a mensagem conforme necessário
                            // Por exemplo: salvar em banco de dados, enviar email, etc.
                            await ProcessMessage(pessoaEvent);
                        }

                        // Acknowledge da mensagem
                        _channel.BasicAck(deliveryTag: ea.DeliveryTag, multiple: false);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Erro ao processar mensagem");

                        // Rejeita a mensagem e não recoloca na fila (dead letter)
                        _channel.BasicNack(
                            deliveryTag: ea.DeliveryTag,
                            multiple: false,
                            requeue: false
                        );
                    }
                };

                _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);

                // Mantém o serviço rodando
                while (!stoppingToken.IsCancellationRequested)
                {
                    await Task.Delay(1000, stoppingToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro no RabbitMQ Consumer Service");
            }
        }

        private async Task ProcessMessage(PessoaEvent pessoaEvent)
        {
            // Implemente aqui a lógica de processamento da mensagem
            await Task.Run(() =>
            {
                switch (pessoaEvent.EventType)
                {
                    case "CREATE":
                        _logger.LogInformation(
                            "Processando criação da pessoa: {Nome}",
                            pessoaEvent.Pessoa?.Nome
                        );
                        break;
                    case "UPDATE":
                        _logger.LogInformation(
                            "Processando atualização da pessoa: {Nome}",
                            pessoaEvent.Pessoa?.Nome
                        );
                        break;
                    case "DELETE":
                        _logger.LogInformation(
                            "Processando exclusão da pessoa ID: {Id}",
                            pessoaEvent.Pessoa?.Id
                        );
                        break;
                    default:
                        _logger.LogWarning(
                            "Tipo de evento desconhecido: {EventType}",
                            pessoaEvent.EventType
                        );
                        break;
                }
            });
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("RabbitMQ Consumer Service parando...");

            if (_channel != null)
            {
                _channel.Close();
                _channel.Dispose();
            }

            if (_connection != null)
            {
                _connection.Close();
                _connection.Dispose();
            }

            await base.StopAsync(cancellationToken);
        }
    }
}
