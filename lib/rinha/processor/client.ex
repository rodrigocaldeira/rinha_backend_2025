defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Schemas.Payment
  alias Rinha.Processor.Services

  require Logger

  def pay(internal_payment) do
    payment = Payment.new(internal_payment)

    case Services.get_service() do
      {:ok, service} ->
        Logger.info("Sending payment #{payment.correlationId} to #{service.name}")

        Req.post("#{service.url}/payments",
          json: payment,
          # retry: :transient,
          finch: Rinha.Finch
        )
        |> case do
          {:ok, %Req.Response{status: 200}} ->
            {:ok, service.name}

          _error ->
            :error
        end

      {:error, :no_service_available} ->
        :error
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
