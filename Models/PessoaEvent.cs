namespace aula_sistemas_backend.Models
{
    public class PessoaEvent
    {
        public string EventType { get; set; } = string.Empty; // CREATE, UPDATE, DELETE
        public Pessoa? Pessoa { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
