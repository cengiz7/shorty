defmodule Shorty.Shortener.Click do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clicks" do
    field :ip_address, :string
    field :referrer, :string
    field :timestamp, :naive_datetime
    field :user_agent, :string
    belongs_to :link, Shorty.Shortener.Link

    timestamps()
  end

  @doc false
  def changeset(click, attrs) do
    click
    |> cast(attrs, [:timestamp, :ip_address, :user_agent, :referrer, :link_id])
    |> validate_required([:timestamp, :ip_address, :user_agent, :link_id])
  end
end
