defmodule ChatWebhook.SlackDriver do
  use HTTPoison.Base

  # Example usage:
  #   event = [user: "George", text: "Room created"]
  #   opts = [channels: ["#general", "#random"], token: "<oauth_token>"]

  def notify(event, opts \\ []) do
    channels = Map.get(opts, "channels", [])

    for channel <- channels, do: notify_channel(channel, event, opts)
  end

  def notify_channel(channel, event, opts \\ []) do
    config = Map.get(opts, "uri") || Application.get_env(:chat_webhook, :slack_client)

    body = [
      token: Map.get(opts, "token"),
      channel: channel,
      attachments: attachment(event)
    ]

    post(config[:uri], body)
  end

  defp attachment(event) do
    [
      %{
        fallback: "Chat Event",
        pretext: "Chat event received:",
        color: attachment_color(Keyword.get(event, :type, "notice")),
        fields: attachment_fields(event)
      }
    ] |> Poison.encode!
  end

  defp attachment_color("notice"), do: "#0f90bb"
  defp attachment_color("error"), do: "#ff0033"

  defp attachment_fields(event) do
    [
      %{
        title: "Event",
        value: Keyword.get(event, :text),
        short: false
      }
    ] ++ attachment_user(Keyword.get(event, :user))
  end

  defp attachment_user(nil), do: []
  defp attachment_user(user), do: [%{title: "User", value: user, short: false}]

  # HTTP Poison URI

  defp process_request_body(body), do: URI.encode_query(body)

  defp process_request_headers(_headers), do: ["Content-Type": "application/x-www-form-urlencoded"]

  # HTTP Poison JSON

  # defp process_request_body(body), do: Poison.encode!(body)

  # defp process_request_headers(_headers), do: ["Content-Type": "application/json; charset=utf-8"]
end
