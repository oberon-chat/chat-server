defmodule ChatServer.Factory do
  use ExMachina.Ecto, repo: ChatServer.Repo

  def message_factory do
    %ChatServer.Schema.Message{
      body: "Test Message",
      room: build(:room),
      user: build(:user)
    }
  end

  def room_factory do
    %ChatServer.Schema.Room{
      name: "Test Room"
    }
  end

  def user_factory do
    %ChatServer.Schema.User{
      name: "Test User"
    }
  end
end
