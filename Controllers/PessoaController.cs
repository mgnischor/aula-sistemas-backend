using Microsoft.AspNetCore.Mvc;

namespace aula_sistemas_backend.Controllers
{
    [ApiController]
    [Route("api/v1/pessoas")]
    public class PessoaController : ControllerBase
    {
        // Modelo de dados
        public class Pessoa
        {
            public Guid Id { get; set; }
            public string Nome { get; set; }
            public string Email { get; set; }
            public string Telefone { get; set; }
            public int? Idade { get; set; }
            public string Endereco { get; set; }
        }

        // Simulação de armazenamento em memória
        private static readonly List<Pessoa> Pessoas = new List<Pessoa>();

        [HttpGet]
        public ActionResult<IEnumerable<Pessoa>> GetAll()
        {
            return Ok(Pessoas);
        }

        [HttpGet("{id}")]
        public ActionResult<Pessoa> GetById(Guid id)
        {
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();
            return Ok(pessoa);
        }

        [HttpPost]
        public ActionResult<Pessoa> Create([FromBody] Pessoa pessoa)
        {
            pessoa.Id = Guid.NewGuid();
            Pessoas.Add(pessoa);
            return CreatedAtAction(nameof(GetById), new { id = pessoa.Id }, pessoa);
        }

        [HttpPut("{id}")]
        public IActionResult Update(Guid id, [FromBody] Pessoa pessoaAtualizada)
        {
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();

            pessoa.Nome = pessoaAtualizada.Nome;
            pessoa.Email = pessoaAtualizada.Email;
            pessoa.Telefone = pessoaAtualizada.Telefone;
            pessoa.Idade = pessoaAtualizada.Idade;
            pessoa.Endereco = pessoaAtualizada.Endereco;

            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(Guid id)
        {
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();

            Pessoas.Remove(pessoa);
            return NoContent();
        }
    }
}