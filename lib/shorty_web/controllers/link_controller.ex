defmodule ShortyWeb.LinkController do
  use ShortyWeb, :controller

  alias Shorty.Shortener
  alias Shorty.Shortener.Link

  def index(conn, _params) do
    links = Shortener.list_links()
    render(conn, :index, links: links)
  end

  def new(conn, _params) do
    changeset = Shortener.change_link(%Link{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Shortener.create_link(link_params) do
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
    link = Shortener.get_link!(slug)
    changeset = Shortener.change_link(link)
    render(conn, :edit, link: link, changeset: changeset)
  end

  def update(conn, %{"slug" => slug, "link" => link_params}) do
    link = Shortener.get_link!(slug)

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
    link = Shortener.get_link!(slug)
    {:ok, _link} = Shortener.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: ~p"/links")
  end
end
