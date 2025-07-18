defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Services

  require Logger

  def pay(payment) do
    case Services.get_service() do
      {:ok, service} ->
        Logger.info("#{payment["correlationId"]} => #{service.name}")

        :httpc.request(
          :post,
          {"#{service.url}/payments", [], ~c"application/json",
           :json.encode(payment) |> to_string()},
          [],
          []
        )
        |> case do
          {:ok, {{_, 200, _}, _, _}} ->
            {:ok, Map.put(payment, "processor", service.name)}

          _error ->
            Services.set_service_health(service.name, true, service.min_response_time)
            pay(payment)
        end

      {:error, :no_service_available} ->
        pay(payment)
    end
  end

  def service_health do
    Services.all_services()
    |> Enum.each(fn service ->
      :httpc.request("#{service.url}/payments/service-health")
      |> case do
        {:ok, {{_, 200, _}, _, body}} ->
          %{
            "failing" => failing,
            "minResponseTime" => min_response_time
          } = :json.decode(to_string(body))

          Services.set_service_health(service.name, failing, min_response_time)

        error ->
          Logger.warning("Error checking service health: #{error}")
      end
    end)

    :ok
  end
end
