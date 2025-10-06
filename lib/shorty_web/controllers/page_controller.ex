defmodule ShortyWeb.PageController do
  use ShortyWeb, :controller

  def home(conn, _params) do
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      redirect(conn, to: ~p"/links")
    else
      render(conn, :home)
    end
  end
end
