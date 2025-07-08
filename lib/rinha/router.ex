defmodule Rinha.Router do
  use Plug.Router

  # alias Plug.Conn

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/payments-summary" do
    {:ok, summary} =
      Rinha.summary(conn.query_params)
      |> Jason.encode()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, summary)
  end

  post "/payments" do
    Rinha.register_payment(conn.body_params)
    |> case do
      :ok -> send_resp(conn, 201, "")
      :error -> bad_request(conn)
    end
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
