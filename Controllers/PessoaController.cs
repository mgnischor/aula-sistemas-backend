using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using StackExchange.Redis;

namespace aula_sistemas_backend.Controllers
{
    [ApiController]
    [Route("api/v1/pessoas")]
    public class PessoaController : ControllerBase
    {
        private readonly IConnectionMultiplexer _redis;
        private readonly IDatabase _db;
        private const string REDIS_KEY_PREFIX = "pessoa:";
        private const string REDIS_ALL_KEY = "pessoas:all";

        public PessoaController(IConnectionMultiplexer redis)
        {
            _redis = redis;
            _db = _redis.GetDatabase();
        }

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
        public async Task<ActionResult<IEnumerable<Pessoa>>> GetAll()
        {
            // Tenta buscar do Redis primeiro
            var cachedData = await _db.StringGetAsync(REDIS_ALL_KEY);

            if (!cachedData.IsNullOrEmpty)
            {
                var pessoasFromCache = JsonSerializer.Deserialize<List<Pessoa>>(cachedData!);
                return Ok(pessoasFromCache);
            }

            // Se não encontrou no Redis, busca da memória
            if (Pessoas.Any())
            {
                // Armazena no Redis para próximas consultas (expira em 5 minutos)
                var json = JsonSerializer.Serialize(Pessoas);
                await _db.StringSetAsync(REDIS_ALL_KEY, json, TimeSpan.FromMinutes(5));
            }

            return Ok(Pessoas);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Pessoa>> GetById(Guid id)
        {
            var redisKey = $"{REDIS_KEY_PREFIX}{id}";

            // Tenta buscar do Redis primeiro
            var cachedData = await _db.StringGetAsync(redisKey);

            if (!cachedData.IsNullOrEmpty)
            {
                var pessoaFromCache = JsonSerializer.Deserialize<Pessoa>(cachedData!);
                return Ok(pessoaFromCache);
            }

            // Se não encontrou no Redis, busca da memória
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();

            // Armazena no Redis para próximas consultas (expira em 5 minutos)
            var json = JsonSerializer.Serialize(pessoa);
            await _db.StringSetAsync(redisKey, json, TimeSpan.FromMinutes(5));

            return Ok(pessoa);
        }

        [HttpPost]
        public async Task<ActionResult<Pessoa>> Create([FromBody] Pessoa pessoa)
        {
            pessoa.Id = Guid.NewGuid();
            Pessoas.Add(pessoa);

            // Armazena no Redis
            var redisKey = $"{REDIS_KEY_PREFIX}{pessoa.Id}";
            var json = JsonSerializer.Serialize(pessoa);
            await _db.StringSetAsync(redisKey, json, TimeSpan.FromMinutes(5));

            // Invalida o cache da lista completa
            await _db.KeyDeleteAsync(REDIS_ALL_KEY);

            return CreatedAtAction(nameof(GetById), new { id = pessoa.Id }, pessoa);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(Guid id, [FromBody] Pessoa pessoaAtualizada)
        {
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();

            pessoa.Nome = pessoaAtualizada.Nome;
            pessoa.Email = pessoaAtualizada.Email;
            pessoa.Telefone = pessoaAtualizada.Telefone;
            pessoa.Idade = pessoaAtualizada.Idade;
            pessoa.Endereco = pessoaAtualizada.Endereco;

            // Atualiza no Redis
            var redisKey = $"{REDIS_KEY_PREFIX}{id}";
            var json = JsonSerializer.Serialize(pessoa);
            await _db.StringSetAsync(redisKey, json, TimeSpan.FromMinutes(5));

            // Invalida o cache da lista completa
            await _db.KeyDeleteAsync(REDIS_ALL_KEY);

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            var pessoa = Pessoas.Find(p => p.Id == id);
            if (pessoa == null)
                return NotFound();

            Pessoas.Remove(pessoa);

            // Remove do Redis
            var redisKey = $"{REDIS_KEY_PREFIX}{id}";
            await _db.KeyDeleteAsync(redisKey);

            // Invalida o cache da lista completa
            await _db.KeyDeleteAsync(REDIS_ALL_KEY);

            return NoContent();
        }
    }
}
