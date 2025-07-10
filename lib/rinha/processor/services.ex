defmodule Rinha.Processor.Services do
  use GenServer

  @impl true
  def init(args), do: {:ok, init_services(args)}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: ProcessorServices)
  end

  def all_services do
    GenServer.call(ProcessorServices, :all_services)
  end

  def get_service do
    GenServer.call(ProcessorServices, :get_service)
  end

  def set_service_health(name, failing, min_response_time) do
    GenServer.cast(
      ProcessorServices,
      {:set_service_health, name, failing, min_response_time}
    )
  end

  @impl true
  def handle_call(:all_services, _from, services) do
    {:reply, services, services}
  end

  def handle_call(:get_service, _from, services) do
    default = get_service_by_name(services, "default")
    fallback = get_service_by_name(services, "fallback")

    service =
      cond do
        default.failing and fallback.failing ->
          {:error, :no_service_available}

        default.failing ->
          {:ok, fallback}

        default.min_response_time >= 1_000 and
            fallback.min_response_time <= 200 ->
          {:ok, fallback}

        true ->
          {:ok, default}
      end

    {:reply, service, services}
  end

  @impl true
  def handle_cast({:set_service_health, name, failing, min_response_time}, services) do
    service = %{
      get_service_by_name(services, name)
      | failing: failing,
        min_response_time: min_response_time
    }

    services =
      services
      |> Enum.filter(&(&1.name != name))
      |> Kernel.++([service])

    {:noreply, services}
  end

  defp init_services(args) do
    Enum.map(args, fn service ->
      service
      |> Map.put(:failing, false)
      |> Map.put(:min_response_time, 0)
    end)
  end

  defp get_service_by_name(services, name) do
    Enum.find(services, &(&1.name == name))
  end
end
