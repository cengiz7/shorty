defmodule ShortyWeb.PageController do
  use ShortyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
