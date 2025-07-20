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
Inicialmente tinha resolvido usar [SQLite3](https://www.sqlite.org/) nesta implementação, porém a concorrência de escrita dos workers estava causando um gargalo no processamento dos pagamentos. Como eu não quis alterar a arquitetura da implementação (detalhes abaixo), resolvi tirar por completo a persistência de dados e trabalhar com os pagamentos totalmente em memória.

### Conteinerização
A mesma aplicação é usada tanto para a API como para o pool de workers. A definição de como a aplicação se comportará é definida via a variável de ambiente `ROLE`:
- `api`: Carrega somente o Server HTTP e expõe os endpoints
- `worker`: Sobe todos os GenServers utilizados

A comunicação entre as APIs e os Workers é feita através da solução do OTP de RPC.

## Tecnologias
- Linguagem: **Elixir**
- Web Server: **Bandit**
- Mensageria, filas, e processamento assíncrono: **Implementado no projeto**

## Dependências utilizadas
- [Bandit](https://hex.pm/packages/bandit): Servidor HTTP

## Resultados parciais
```plain
     balance_inconsistency_amount...: 0        0/s
     data_received..................: 3.4 MB   55 kB/s
     data_sent......................: 3.4 MB   55 kB/s
     default_total_amount...........: 260451.2 4266.130936/s
     default_total_fee..............: 13022.56 213.306547/s   
     default_total_requests.........: 13088    214.378439/s                   
     fallback_total_amount..........: 72754.4  1191.70039/s
     fallback_total_fee.............: 10913.16 178.755058/s
     fallback_total_requests........: 3656     59.884442/s
     http_req_blocked...............: p(99)=202.23µs count=16794
     http_req_connecting............: p(99)=140.92µs count=16794
     http_req_duration..............: p(99)=3.44ms   count=16794
       { expected_response:true }...: p(99)=3.44ms   count=16794                                                                                                                   http_req_failed................: 0.00%    ✓ 0           ✗ 16794
     http_req_receiving.............: p(99)=266.99µs count=16794
     http_req_sending...............: p(99)=62.64µs  count=16794
     http_req_tls_handshaking.......: p(99)=0s       count=16794
     http_req_waiting...............: p(99)=3.35ms   count=16794                                                                                                                   http_reqs......................: 16794    275.081869/s
     iteration_duration.............: p(99)=1s       count=16756
     iterations.....................: 16756    274.459438/s
     total_transactions_amount......: 333205.6 5457.831325/s
     transactions_failure...........: 0        0/s
     transactions_success...........: 16744    274.262881/s                                                                                                                                                       
     vus............................: 104      min=9         max=549
```
