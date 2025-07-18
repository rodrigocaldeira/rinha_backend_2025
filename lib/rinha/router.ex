defmodule Rinha.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["application/json"]
  )

  plug(:match)
  plug(:dispatch)

  get "/payments-summary" do
    summary =
      Rinha.summary(conn.query_params)
      |> :json.encode()
      |> to_string()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, summary)
  end

  post "/payments" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])
    worker_address = Application.get_env(:rinha, :queue_address)

    send(
      worker_address,
      {:enqueue,
       Map.put(
         :json.decode(body),
         "requestedAt",
         DateTime.to_iso8601(DateTime.utc_now(:millisecond))
       )}
    )

    send_resp(conn, 201, "")
  end

  post "/purge-payments" do
    Rinha.purge()

    send_resp(conn, 200, "")
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, "{\"error\":\"Not found\"}")
  end

  def bad_request(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, "{\"error\":\"Bad request\"}")
  end
end
