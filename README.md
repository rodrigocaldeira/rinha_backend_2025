# Rinha de Backend - 2025
Implementação em Elixir da [**Rinha de Backend - 2025**](https://github.com/zanfranceschi/rinha-de-backend-2025).

## Principais focos desta implementação
- Aprender
- Aprender
- Utilizar o mínimo possível de dependências externas
- Resolver o máximo do desafio usando somente Elixir e OTP
- Aprender

## Implementação
### API
A API está toda definida no Router usando somente [Plugs](https://hexdocs.pm/plug/readme.html). Não foi utilizado o [Phoenix Framework](https://phoenixframework.org/) ou outro framework nesta implementação.
Cada endpoint está mapeado para uma função específica no domínio da aplicação. Existe tratamento para erros 404 e 400.

### Processamento assíncrono
Poderia ter usado Redis ou alguma outra solução de mensageria nesta implementação, mas decidi implementar a solução para este desafio para ver se seria possível resolver isso sem depender de uma solução externa.

A solução principal foi utilizar [GenServers](https://hexdocs.pm/elixir/1.18.2/GenServer.html) para:
- Gestão de estado, para ter em memória o estado mais recente dos payment processors (se estão falhando e o tempo de resposta)
- Fila, para receber os requests de pagamento e devolver um response o mais rápido possível. Todos os pagamentos são pendentes são salvos em memória
- Processamento assíncrono dos pagamentos, através da criação de workers que consomem da fila e se integram com os payment processors. Foi inclusive implementada de uma solução para pool de workers, onde é possível configurar a quantidade de workers desejada

### Persistência de dados
Resolvi usar [SQLite3](https://www.sqlite.org/) nesta implementação, só para sair um pouco do Postgres e também para deixar mais recursos disponíveis para a aplicação, dada as limitações impostas no desafio.

### Conteinerização
A mesma aplicação é usada tanto para a API como para o pool de workers. A definição de como a aplicação se comportará é definida via a variável de ambiente `ROLE`:
- `api`: Carrega somente o Server HTTP e expõe os endpoints
- `worker`: Sobe todos os GenServers utilizados

A comunicação entre as APIs e os Workers é feita através da solução do OTP de RPC.

Porém, para o desenvolvimento e testes locais não é necessário subir mais de uma aplicação. Atráves da variável de ambiente `ROLE`, a aplicação consegue entender que está rodando em uma única instância, e altera a forma de comunicação entre a API e os Workers para chamada direta das funções.

## Tecnologias
- Linguagem: **Elixir**
- Web Server: **Bandit**
- Banco de dados: **SQLite3**
- Mensageria, filas, e processamento assíncrono: **Implementado no projeto**

## Dependências utilizadas
- [Bandit](https://hex.pm/packages/bandit): Servidor HTTP
- [Req](https://hex.pm/packages/req): Cliente HTTP
- [Ecto](https://hex.pm/packages/ecto): Data Mapper
- [Ecto SQLite3](https://hex.pm/packages/ecto_sqlite3): Adapter para SQLite3

## Resultados parciais
```plain
     balance_inconsistency_amount...: 0        0/s
     data_received..................: 3.1 MB   50 kB/s
     data_sent......................: 3.1 MB   50 kB/s
     default_total_amount...........: 159399   2610.555888/s
     default_total_fee..............: 7969.95  130.527794/s
     default_total_requests.........: 8010     131.183713/s
     fallback_total_amount..........: 27342.6  447.80322/s
     fallback_total_fee.............: 4101.39  67.170483/s
     fallback_total_requests........: 1374     22.502674/s
     http_req_blocked...............: p(99)=118.36µs count=15279
     http_req_connecting............: p(99)=82.09µs  count=15279
     http_req_duration..............: p(99)=2.94ms   count=15279
       { expected_response:true }...: p(99)=2.94ms   count=15279
     http_req_failed................: 0.00%    ✓ 0           ✗ 15279
     http_req_receiving.............: p(99)=84.89µs  count=15279
     http_req_sending...............: p(99)=42.27µs  count=15279
     http_req_tls_handshaking.......: p(99)=0s       count=15279
     http_req_waiting...............: p(99)=2.86ms   count=15279
     http_reqs......................: 15279    250.231704/s
     iteration_duration.............: p(99)=1s       count=15241
     iterations.....................: 15241    249.609359/s
     total_transactions_amount......: 186741.6 3058.359107/s
     transactions_failure...........: 0        0/s
     transactions_success...........: 15229    249.41283/s
     vus............................: 79       min=9         max=499
```
