defmodule Rinha.DB do

  @zero_summary %{
      "default" => %{
        "totalAmount" => 0.0,
        "totalRequests" => 0
      },
      "fallback" => %{
        "totalAmount" => 0.0,
        "totalRequests" => 0
      }
    }

  def purge, do: :ets.delete_all_objects(:rinha_db)

  def pay(payment) do
    :ets.insert(:rinha_db, {
      payment["correlationId"],
      payment["requestedAt"],
      payment["processor"],
      payment["amount"]
    })
  end

  def summary(from, to) do
    {summaries, _} =
      :rpc.multicall(
        Node.list([:this, :visible]),
        Rinha.DB,
        :get_local_summary,
        [from, to],
        :infinity
      )

    Enum.reduce(summaries, @zero_summary, fn summary, acc ->
      acc
      |> update_processor_data("default", summary)
      |> update_processor_data("fallback", summary)
    end)
  end

  defp update_processor_data(summary, processor_name, node_summary) do
    Map.update(summary, processor_name, nil, fn processor ->
      total_amount = processor["totalAmount"] + node_summary[processor_name]["totalAmount"]
      total_requests = processor["totalRequests"] + node_summary[processor_name]["totalRequests"]

      %{
        "totalAmount" => Float.round(total_amount, 2),
        "totalRequests" => total_requests
      }
    end)
  end

  def get_local_summary(nil, nil), do: create_summary(:ets.tab2list(:rinha_db))
  def get_local_summary(from, to) do
    filter = filter_function(from, to)

    match_spec = [
      {
        {:"$1", :"$2", :"$3", :"$4"},
        filter,
        [:"$_"]
      }
    ]

    create_summary(:ets.select(:rinha_db, match_spec))
  end

  defp create_summary(payments) do
    Enum.reduce(payments, @zero_summary, fn {_, _, processor, amount}, acc ->
      Map.update(acc, processor, nil, fn processor_details ->
        total_amount = processor_details["totalAmount"] + amount
        total_requests = processor_details["totalRequests"] + 1

        %{
          "totalAmount" => Float.round(total_amount, 2),
          "totalRequests" => total_requests
        }
      end)
    end)
  end

  def filter_function(from, nil) when not is_nil(from) do
    [{:andalso, {:>=, :"$2", from}}]
  end

  def filter_function(nil, to) when not is_nil(to) do
    [{:andalso, {:"=<", :"$2", to}}]
  end

  def filter_function(from, to) do
    [{:andalso, {:>=, :"$2", from}, {:"=<", :"$2", to}}]
  end
end
