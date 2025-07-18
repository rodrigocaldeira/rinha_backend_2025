# Rinha de Backend - 2025
Implementação em Elixir da [**Rinha de Backend - 2025**](https://github.com/zanfranceschi/rinha-de-backend-2025).

## Principais focos desta implementação
- Aprender
- Aprender
- Utilizar o mínimo possível de dependências externas
- Resolver o máximo do desafio usando somente Elixir, Erlang e OTP
- Aprender

## Implementação
### API
A API está toda definida no Router usando somente [Plugs](https://hexdocs.pm/plug/readme.html). Não foi utilizado o [Phoenix Framework](https://phoenixframework.org/) ou outro framework nesta implementação.
Cada endpoint está mapeado para uma função específica no domínio do desafio. Existe tratamento para erros 404 e 400.

### Processamento assíncrono
Poderia ter usado Redis ou alguma outra solução de mensageria nesta implementação, mas decidi implementar a solução para este desafio para ver se seria possível resolver isso sem depender de uma solução externa, e de certa forma foi possível.

A solução principal foi utilizar [GenServers](https://hexdocs.pm/elixir/1.18.2/GenServer.html) e um [Agent](https://hexdocs.pm/elixir/1.18.2/Agent.html) para:
- Gestão de estado, para ter em memória o estado mais recente dos payment processors (se estão falhando e o tempo de resposta)
- Fila, para receber os requests de pagamento e devolver um response o mais rápido possível. Todos os pagamentos pendentes são salvos na fila, que é em memória
- Processamento assíncrono dos pagamentos, através da criação de workers que consomem da fila e se integram com os payment processors. Foi inclusive implementada de uma solução para pool de workers, onde é possível configurar a quantidade de workers desejada

### Persistência de dados
Resolvi usar [SQLite3](https://www.sqlite.org/) nesta implementação, só para sair um pouco do Postgres.

### Conteinerização
A mesma aplicação é usada tanto para a API como para o pool de workers. A definição de como a aplicação se comportará é definida via a variável de ambiente `ROLE`:
- `api`: Carrega somente o Server HTTP e expõe os endpoints
- `worker`: Sobe todos os GenServers utilizados

A comunicação entre as APIs e os Workers é feita através da solução do OTP de RPC.

## Tecnologias
- Linguagem: **Elixir**
- Web Server: **Bandit**
- Banco de dados: **SQLite3**
- Mensageria, filas, e processamento assíncrono: **Implementado no projeto**

## Dependências utilizadas
- [Bandit](https://hex.pm/packages/bandit): Servidor HTTP
- [Ecto](https://hex.pm/packages/ecto): Data Mapper
- [Ecto SQLite3](https://hex.pm/packages/ecto_sqlite3): Adapter para SQLite3

## Resultados parciais
```plain
     balance_inconsistency_amount...: 0        0/s
     data_received..................: 3.4 MB   55 kB/s
     data_sent......................: 3.4 MB   55 kB/s
     default_total_amount...........: 143200.4 2342.872723/s
     default_total_fee..............: 7160.02  117.143636/s
     default_total_requests.........: 7196     117.732298/s
     fallback_total_amount..........: 72794.2  1190.971154/s
     fallback_total_fee.............: 10919.13 178.645673/s
     fallback_total_requests........: 3658     59.847797/s
     http_req_blocked...............: p(99)=196.17µs count=16797
     http_req_connecting............: p(99)=137.82µs count=16797
     http_req_duration..............: p(99)=3.17ms   count=16797
       { expected_response:true }...: p(99)=3.17ms   count=16797
     http_req_failed................: 0.00%    ✓ 0           ✗ 16797
     http_req_receiving.............: p(99)=215.33µs count=16797
     http_req_sending...............: p(99)=57.3µs   count=16797
     http_req_tls_handshaking.......: p(99)=0s       count=16797
     http_req_waiting...............: p(99)=3.08ms   count=16797
     http_reqs......................: 16797    274.812313/s
     iteration_duration.............: p(99)=1s       count=16759
     iterations.....................: 16759    274.190603/s
     total_transactions_amount......: 215994.6 3533.843876/s
     transactions_failure...........: 0        0/s
     transactions_success...........: 16747    273.994273/s
     vus............................: 107      min=9         max=549
```

## Notas
Ainda não consegui resolver a questão do throughput do worker quando conteinerizado, fazendo com que transações fiquem pendentes na fila após a execução do teste. Rodando a aplicação localmente através do comando `PORT=9999 iex -S mix` todas as transações são processadas corretamente.
