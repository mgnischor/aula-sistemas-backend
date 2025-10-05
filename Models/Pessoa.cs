namespace aula_sistemas_backend.Models
{
    public class Pessoa
    {
        public Guid Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Telefone { get; set; } = string.Empty;
        public int? Idade { get; set; }
        public string Endereco { get; set; } = string.Empty;
    }
}
