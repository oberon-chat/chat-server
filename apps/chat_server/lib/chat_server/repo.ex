defmodule ChatServer.Repo do
  use Ecto.Repo, otp_app: :chat_server
  use Scrivener, page_size: 25
end
