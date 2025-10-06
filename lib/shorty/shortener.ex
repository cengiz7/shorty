defmodule Shorty.Shortener do
  @moduledoc """
  The Shortener context.
  """

  import Ecto.Query, warn: false
  alias Shorty.Repo

  alias Shorty.Shortener.Link
  alias Shorty.Shortener.Click
  alias Shorty.Accounts.User

  @topic "links"

  def subscribe do
    Phoenix.PubSub.subscribe(Shorty.PubSub, @topic)
  end

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
  def get_user_link!(%User{} = user, slug) do
    Repo.get_by!(Link, user_id: user.id, slug: slug)
  end

  @doc """
  Gets a single link with its clicks.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link_with_clicks!(123)
      %Link{clicks: [%Click{}, ...]}

      iex> get_link_with_clicks!(456)
      ** (Ecto.NoResultsError)

  """
  def get_link_with_clicks!(slug) do
    Repo.get_by!(Link, slug: slug)
    |> Repo.preload(:clicks)
  end

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
    chars = Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z) ++ Enum.to_list(?0..?9)
    slug =
      for _ <- 1..6, into: ~c"" do
        Enum.random(chars)
      end
      |> then(&to_string/1)

    case Repo.get_by(Link, slug: slug) do
      nil ->
        slug

      _ ->
        generate_slug()
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
    case Repo.get_by(Link, slug: slug) do
      nil ->
        {:error, :not_found}

      link ->
        link
        |> Ecto.Changeset.change(%{view_count: link.view_count + 1})
        |> Repo.update()
        |> then(fn result ->
          case result do
          {:ok, updated_link} ->
            Task.async(fn -> Phoenix.PubSub.broadcast(Shorty.PubSub, @topic, {:link_updated, updated_link}) end)
            {:ok, updated_link}

          error ->
            error
          end
        end)
    end
  end

  @doc """
  Creates a click.

  ## Examples

      iex> create_click(%{field: :value})
      {:ok, %Click{}}

      iex> create_click(%{field: :bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_click(attrs \\ %{}) do
    %Click{}
    |> Click.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Tracks a click for a link.
  """
  def track_click(link, ip_address, user_agent, referrer) do
    attrs = %{
      link_id: link.id,
      timestamp: NaiveDateTime.utc_now(),
      ip_address: ip_address,
      user_agent: user_agent,
      referrer: referrer
    }

    create_click(attrs)
  end

  @doc """
  Paginates the clicks for a link.
  """
  def paginate_clicks_for_link(link, page) do
    page_size = 5
    page = if is_nil(page) || page < 1, do: 1, else: page |> trunc

    base_query = from c in Click, where: c.link_id == ^link.id

    query = order_by(base_query, [c], desc: c.inserted_at)

    offset = (page - 1) * page_size
    entries_query = query |> limit(^page_size) |> offset(^offset)

    entries = Repo.all(entries_query)
    total_entries = Repo.one(from c in base_query, select: count(c.id))
    total_pages = if total_entries > 0, do: ceil(total_entries / page_size) |> trunc, else: 1

    %{
      entries: entries,
      page_number: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end
end
