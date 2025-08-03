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

A solução principal foi utilizar [GenServers](https://hexdocs.pm/elixir/1.18.2/GenServer.html) para:
- Gestão de estado, para ter em memória o estado mais recente dos payment processors (se estão falhando e o tempo de resposta)
- Fila, para receber os requests de pagamento e devolver um response o mais rápido possível. Todos os pagamentos pendentes são salvos na fila, que é em memória
- Processamento assíncrono dos pagamentos, através da criação de workers que consomem da fila e se integram com os payment processors. Foi inclusive implementada de uma solução para pool de workers, onde é possível configurar a quantidade de workers desejada

### Persistência de dados
Inicialmente tinha resolvido usar [SQLite3](https://www.sqlite.org/) nesta implementação, porém a concorrência de escrita dos workers estava causando um gargalo no processamento dos pagamentos. Como eu não quis alterar a arquitetura da implementação, resolvi tirar por completo a persistência de dados e trabalhar com os pagamentos usando primeiramente usando :queue, Agents e GenServers, porém os testes oficiais continuavam falhando e olhei a implementação usando ETS do [oliveigah](https://github.com/oliveigah) em https://github.com/oliveigah/rinha_backend_v3 e decidi testar a implementação dele. E deu bom! Parabéns oliveigah!

## Tecnologias
- Linguagem: **Elixir**
- Web Server: **Bandit**
- Mensageria, filas, e persistência de dados: **Implementado no projeto**

## Dependências utilizadas
- [Bandit](https://hex.pm/packages/bandit): Servidor HTTP

