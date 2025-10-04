defmodule Shorty.Shortener.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :original_url, :string
    field :slug, :string
    field :title, :string
    field :view_count, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:original_url, :slug, :title])
    |> validate_required([:original_url, :slug, :title])
    |> unique_constraint(:slug)
  end
end
