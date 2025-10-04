defmodule ShortyWeb.LinkHTML do
  use ShortyWeb, :html

  embed_templates "link_html/*"

  @doc """
  Renders a link form.

  The form is defined in the template at
  link_html/link_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def link_form(assigns)
end
