defmodule Rinha.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["application/json"]
  )

  plug(:match)
  plug(:dispatch)

  get "/health-check" do
    send_resp(conn, 200, "")
  end

  get "/payments-summary" do
    summary =
      Rinha.summary(conn.query_params["from"], conn.query_params["to"])
      |> :json.encode()
      |> to_string()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, summary)
  end

  post "/payments" do
    {:ok, body, conn} = Plug.Conn.read_body(conn, [])

    Rinha.Queue.enqueue(
      Map.put(
        :json.decode(body),
        "requestedAt",
        DateTime.to_iso8601(DateTime.utc_now(:millisecond))
      )
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
end
