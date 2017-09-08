defmodule ChatWebhook.HttpDriver do
  use HTTPoison.Base

  def notify(event, opts \\ []) do
    body = %{
      type: Keyword.get(event, :type),
      user: Keyword.get(event, :user),
      text: Keyword.get(event, :text)
    }

    post(uri(opts), body)
  end

  def uri(opts), do: Map.get(opts, "uri") || Application.get_env(:chat_webhook, :slack_client)[:uri]

  # HTTP Poison JSON

  defp process_request_body(body), do: Poison.encode!(body)

  defp process_request_headers(_headers), do: ["Content-Type": "application/json; charset=utf-8"]
end
