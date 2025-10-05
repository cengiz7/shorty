defmodule Shorty.Shortener.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :original_url, :string
    field :slug, :string
    field :title, :string
    field :view_count, :integer

    belongs_to :user, Shorty.Accounts.User

    has_many :clicks, Shorty.Shortener.Click

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:original_url, :slug, :title, :user_id])
    |> validate_required([:original_url, :slug, :title, :user_id])
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id)
    |> validate_and_sanitize_url()
  end

  defp validate_and_sanitize_url(changeset) do
    case get_change(changeset, :original_url) do
      nil ->
        changeset

      url ->
        sanitized_url = prepend_http_if_missing(url)

        case URI.parse(sanitized_url) do
          %URI{scheme: "http", host: host} when is_binary(host) ->
            put_change(changeset, :original_url, sanitized_url)

          %URI{scheme: "https", host: host} when is_binary(host) ->
            put_change(changeset, :original_url, sanitized_url)

          _ ->
            add_error(changeset, :original_url, "is not a valid URL")
        end
    end
  end

  defp prepend_http_if_missing(url) do
    if String.starts_with?(url, "http://") or String.starts_with?(url, "https://") do
      url
    else
      "http://" <> url
    end
  end
end
