defmodule Rinha.Processor.Services do
  use GenServer

  @impl true
  def init(services) do
    Enum.each(services, fn service ->
      processor = elem(service, 0)
      :persistent_term.put({__MODULE__, processor}, service)
    end)

    Process.send_after(self(), :health, 5_001)

    {:ok, nil}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_service do
    {
      _,
      default_url,
      default_failing,
      default_min_response_time
    } = get_service_by_name("default")

    {
      _,
      fallback_url,
      fallback_failing,
      fallback_min_response_time
    } = get_service_by_name("fallback")

    cond do
      default_failing and fallback_failing ->
        {:error, :no_service_available}

      default_failing ->
        {:ok, {"fallback", fallback_url}}

      default_min_response_time >= 1_000 and
          fallback_min_response_time <= 200 ->
        {:ok, {"fallback", fallback_url}}

      true ->
        {:ok, {"default", default_url}}
    end
  end

  def set_service_health(name, failing, min_response_time \\ nil) do
    params =
      case min_response_time do
        nil -> [name, failing]
        min_response_time -> [name, failing, min_response_time]
      end

    :rpc.multicall(
      Node.list([:this, :visible]),
      Rinha.Processor.Services,
      :set_node_service_health,
      params,
      :infinity
    )
  end

  def set_node_service_health(name, failing) do
    {_, url, _, min_response_time} = get_service_by_name(name)

    :persistent_term.put({__MODULE__, name}, {
      name,
      url,
      failing,
      min_response_time
    })
  end

  def set_node_service_health(name, failing, min_response_time) do
    {_, url, _, _} = get_service_by_name(name)

    :persistent_term.put({__MODULE__, name}, {
      name,
      url,
      failing,
      min_response_time
    })
  end

  @impl true
  def handle_info(:health, state) do
    [
      get_service_by_name("default"),
      get_service_by_name("fallback")
    ]
    |> Enum.each(fn {processor, url, _, _} ->
      :httpc.request("#{url}/payments/service-health")
      |> case do
        {:ok, {{_, 200, _}, _, body}} ->
          %{
            "failing" => failing,
            "minResponseTime" => min_response_time
          } = :json.decode(to_string(body))

          set_service_health(processor, failing, min_response_time)

        _error ->
          :ok
      end
    end)

    Process.send_after(self(), :health, 5_001)

    {:noreply, state}
  end

  defp get_service_by_name(name) do
    :persistent_term.get({__MODULE__, name})
  end
end
