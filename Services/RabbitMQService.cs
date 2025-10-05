using System.Text;
using System.Text.Json;
using aula_sistemas_backend.Models;
using RabbitMQ.Client;

namespace aula_sistemas_backend.Services
{
    public interface IRabbitMQService
    {
        void PublishMessage<T>(T message, string routingKey);
    }

    public class RabbitMQService : IRabbitMQService, IDisposable
    {
        private readonly IConnection _connection;
        private readonly IModel _channel;
        private readonly string _exchangeName;
        private readonly ILogger<RabbitMQService> _logger;
        private bool _disposed = false;

        public RabbitMQService(IConfiguration configuration, ILogger<RabbitMQService> logger)
        {
            _logger = logger;

            var factory = new ConnectionFactory
            {
                HostName = configuration["RabbitMQ:HostName"],
                Port = int.Parse(configuration["RabbitMQ:Port"] ?? "5672"),
                UserName = configuration["RabbitMQ:UserName"],
                Password = configuration["RabbitMQ:Password"],
                VirtualHost = configuration["RabbitMQ:VirtualHost"],
            };

            _exchangeName = configuration["RabbitMQ:ExchangeName"] ?? "pessoas_exchange";

            try
            {
                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();

                // Declara o exchange do tipo 'topic'
                _channel.ExchangeDeclare(
                    exchange: _exchangeName,
                    type: ExchangeType.Topic,
                    durable: true,
                    autoDelete: false
                );

                _logger.LogInformation("RabbitMQ conectado com sucesso!");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao conectar ao RabbitMQ");
                throw;
            }
        }

        public void PublishMessage<T>(T message, string routingKey)
        {
            try
            {
                var json = JsonSerializer.Serialize(message);
                var body = Encoding.UTF8.GetBytes(json);

                var properties = _channel.CreateBasicProperties();
                properties.Persistent = true;
                properties.ContentType = "application/json";
                properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

                _channel.BasicPublish(
                    exchange: _exchangeName,
                    routingKey: routingKey,
                    mandatory: false,
                    basicProperties: properties,
                    body: body
                );

                _logger.LogInformation("Mensagem publicada: {RoutingKey}", routingKey);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao publicar mensagem no RabbitMQ");
                throw;
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    _channel?.Close();
                    _connection?.Close();
                    _channel?.Dispose();
                    _connection?.Dispose();
                }
                _disposed = true;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
