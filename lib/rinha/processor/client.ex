defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Services

  def pay(payment, processor, url) do
    :httpc.request(
      :post,
      {"#{url}/payments", [], ~c"application/json", :json.encode(payment) |> to_string()},
      [],
      []
    )
    |> case do
      {:ok, {{_, 200, _}, _, _}} ->
        {:ok, Map.put(payment, "processor", processor)}

      _error ->
        Services.set_service_health(processor, true)
        {:error, :no_service_available}
    end
  end
end
