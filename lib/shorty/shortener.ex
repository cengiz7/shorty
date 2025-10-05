defmodule Shorty.Shortener do
  @moduledoc """
  The Shortener context.
  """

  import Ecto.Query, warn: false
  alias Shorty.Repo

  alias Shorty.Shortener.Link
  alias Shorty.Accounts.User


  @doc """
  Returns the list of links for a user.

  ## Examples

      iex> list_links(user)
      [%Link{}, ...]

  """
  def list_links(%User{} = user) do
    Repo.all(from l in Link, where: l.user_id == ^user.id)
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(123)
      %Link{}

      iex> get_link!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(slug), do: Repo.get_by!(Link, slug: slug)

  @doc """
  Creates a link for a user.

  ## Examples

      iex> create_link(user, %{field: value})
      {:ok, %Link{}}

      iex> create_link(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(%User{} = user, attrs \\ %{}) do
    slug = generate_slug()
    attrs_with_slug = Map.put(attrs, "slug", slug)

    %Link{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Link.changeset(attrs_with_slug)
    |> Ecto.Changeset.put_change(:view_count, 0)
    |> Repo.insert()
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(link)
      {:ok, %Link{}}

      iex> delete_link(link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(link)
      %Ecto.Changeset{data: %Link{}}

  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end


  # Generates a unique, URL-safe, 6-character slug.
  defp generate_slug do
    slug =
      :crypto.strong_rand_bytes(6)
      |> Base.url_encode64()
      |> binary_part(0, 6)

    case Repo.get_by(Link, slug: slug) do
      nil -> slug
      _ -> generate_slug()
    end
  end

  @doc """
  Gets a single link and increments the view count.

  Returns `nil` if the Link does not exist.

  ## Examples

      iex> get_link_and_increment_view_count("abc")
      %Link{}

      iex> get_link_and_increment_view_count("xyz")
      nil

  """
  def get_link_and_increment_view_count(slug) do
    IO.inspect([slug, "slug bu"])
    case Repo.get_by(Link, slug: slug) do
      nil ->
        {:error, :not_found}

      link ->
        link
        |> Ecto.Changeset.change(%{view_count: link.view_count + 1})
        |> Repo.update()
    end
  end
end
