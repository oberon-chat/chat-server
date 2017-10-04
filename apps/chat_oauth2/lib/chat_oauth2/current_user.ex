defmodule ChatOAuth2.CurrentUser do
  def present?(%{context: %{current_user: %{id: _id}}}), do: true
  def present?(_), do: false

  def id(%{context: %{current_user: %{id: id}}}), do: id
  def id(_, _), do: nil

  def add(map, %{context: %{current_user: %{id: _id}}} = info),
    do: Map.put(map, :user_id, id(info))
  def add(map, _), do: map
end
