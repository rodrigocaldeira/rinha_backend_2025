defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Schemas.Payment
  alias Rinha.Processor.Services

  require Logger

  def pay(payment) do
    case Services.get_service() do
      {:ok, service} ->
        Logger.info("Sending payment #{payment["correlationId"]} to #{service.name}")

        Req.post("#{service.url}/payments",
          json: payment,
          finch: Rinha.Finch,
          retry: false
        )
        |> case do
          {:ok, %Req.Response{status: 200}} ->
            {:ok, service.name}

          {:ok, %Req.Response{status: 500}} ->
            Services.set_service_health(service.name, true, service.min_response_time)
            Logger.warning("Service #{service.name} down.")
            pay(payment)

          {:ok, %Req.Response{status: 429}} ->
            Services.set_service_health(service.name, true, service.min_response_time)
            Logger.warning("Service #{service.name} overloaded.")
            pay(payment)

          _error ->
            :error
        end

      {:error, :no_service_available} ->
        Process.sleep(500)
        pay(payment)
    end
  end

  def service_health do
    Services.all_services()
    |> Enum.each(fn service ->
      Req.get("#{service.url}/payments/service-health",
        retry: false,
        finch: Rinha.Finch
      )
      |> case do
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "failing" => failing,
             "minResponseTime" => minResponseTime
           }
         }} ->
          Services.set_service_health(service.name, failing, minResponseTime)

        error ->
          Logger.warning("Error checking service health: #{error}")
      end
    end)

    :ok
  end

  def purge do
    Services.all_services()
    |> Enum.each(fn service ->
      Req.post("#{service.url}/admin/purge-payments",
        headers: [{"X-Rinha-Token", "123"}]
      )
    end)

    :ok
  end
end
