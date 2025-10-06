defmodule ShortyWeb.LinkLive.Index do
  use ShortyWeb, :live_view

  alias Shorty.Shortener
  alias Shorty.Shortener.Link

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Links")
    |> assign(:link, nil)
    |> assign(:links, Shortener.list_links(socket.assigns.current_scope.user))
  end

  @impl true
  def handle_event("delete", %{"slug" => slug}, socket) do
    current_user = socket.assigns.current_scope.user
    link = Shortener.get_user_link!(current_user, slug)

    if link.user_id == current_user.id do
      {:ok, _} = Shortener.delete_link(link)

      {:noreply,
       socket
       |> put_flash(:info, "Link deleted successfully.")
       |> assign(:links, Shortener.list_links(current_user))}
    else
      {:noreply, put_flash(socket, :error, "You are not authorized to delete this link.")}
    end
  end
end
