defmodule Shorty.ShortenerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shorty.Shortener` context.
  """

  @doc """
  Generate a unique link slug.
  """
  def unique_link_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        original_url: "some original_url",
        slug: unique_link_slug(),
        title: "some title",
        view_count: 42
      })
      |> Shorty.Shortener.create_link()

    link
  end
end
