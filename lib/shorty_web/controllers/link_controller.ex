defmodule ShortyWeb.LinkController do
  use ShortyWeb, :controller

  alias Shorty.Shortener
  alias Shorty.Shortener.Link

  plug :authorize_link when action in [:edit, :update, :delete]

  def index(conn, _params) do
    links = Shortener.list_links(conn.assigns.current_scope.user)
    render(conn, :index, links: links)
  end

  def new(conn, _params) do
    changeset = Shortener.change_link(%Link{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Shortener.create_link(conn.assigns.current_scope.user, link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: ~p"/links/#{link.slug}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "There was an error creating the link.")
        |> render(:new, changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    link = Shortener.get_link!(slug)
    render(conn, :show, link: link)
  end

  def edit(conn, %{"slug" => slug}) do
    link = conn.assigns.link
    changeset = Shortener.change_link(link)
    render(conn, :edit, link: link, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "link" => link_params}) do
    link = conn.assigns.link

    case Shortener.update_link(link, link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link updated successfully.")
        |> redirect(to: ~p"/links/#{link.slug}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, link: link, changeset: changeset)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    link = conn.assigns.link
    {:ok, _link} = Shortener.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: ~p"/links")
  end

  def redirect_to_original(conn, %{"slug" => slug}) do
    case Shortener.get_link_and_increment_view_count(slug) do
      {:ok, link} ->
        redirect(conn, external: link.original_url)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Link not found.")
        |> redirect(to: ~p"/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not update link.")
        |> redirect(to: ~p"/")
    end
  end

  defp authorize_link(conn, _opts) do
    link = Shortener.get_link!(conn.params["slug"])

    if conn.assigns.current_scope && conn.assigns.current_scope.user &&
         link.user_id == conn.assigns.current_scope.user.id do
      assign(conn, :link, link)
    else
      conn
      |> put_flash(:error, "You are not authorized to perform this action.")
      |> redirect(to: ~p"/links")
      |> halt()
    end
  end
end
