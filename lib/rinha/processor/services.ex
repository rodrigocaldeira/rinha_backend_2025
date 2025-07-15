defmodule Rinha.Processor.Services do
  use Agent

  def start_link(args) do
    Agent.start_link(fn -> init_services(args) end, name: __MODULE__)
  end

  def all_services do
    Agent.get(__MODULE__, & &1)
  end

  def get_service do
    Agent.get(__MODULE__, fn services ->
      default = get_service_by_name(services, "default")
      fallback = get_service_by_name(services, "fallback")

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
    end)
  end

  def set_service_health(name, failing, min_response_time) do
    Agent.update(__MODULE__, fn services ->
      service = %{
        get_service_by_name(services, name)
        | failing: failing,
          min_response_time: min_response_time
      }

      services
      |> Enum.filter(&(&1.name != name))
      |> Kernel.++([service])
    end)
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
