defmodule Rinha.Processor.Client do
  alias Rinha.Processor.Schemas.Payment
  alias Rinha.Processor.Services
  alias Rinha.Schemas.Payment, as: InternalPayment

  require Logger

  def pay(%InternalPayment{} = internal_payment) do
    payment = Payment.new(internal_payment)

    service = Services.get_service

    Req.post("#{service.url}/payments", json: payment)
    |> case do
      {:ok, %Req.Response{status: 200}} ->
        {:ok, service.name}

      error ->
        IO.inspect(error)
        {:error, :processor_error}
    end
  end

  def service_health do
    Services.all_services
    |> Enum.each(fn service ->
      Req.get("#{service.url}/payments/service-health")
      |> case do
        {:ok, %Req.Response{
          status: 200, 
          body: %{
            "failing" => failing, 
            "minResponseTime" => minResponseTime
          }}} ->
          
          Logger.debug("Service #{service.name} health: #{failing} - #{minResponseTime}")
          Services.set_service_health(service.name, failing, minResponseTime)

        error ->
          Logger.warning("Error checking service health: #{error}")
      end
    end)

    :ok
  end

  def purge do
    Services.all_services
    |> Enum.each(fn service ->
      Req.post("#{service.url}/admin/purge-payments",
        headers: [{"X-Rinha-Token", "123"}])
    end)

    :ok
  end
end
