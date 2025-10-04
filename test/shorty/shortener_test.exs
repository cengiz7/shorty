defmodule Shorty.ShortenerTest do
  use Shorty.DataCase

  alias Shorty.Shortener

  describe "links" do
    alias Shorty.Shortener.Link

    import Shorty.ShortenerFixtures

    @invalid_attrs %{title: nil, original_url: nil, slug: nil, view_count: nil}

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Shortener.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Shortener.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      valid_attrs = %{title: "some title", original_url: "some original_url", slug: "some slug", view_count: 42}

      assert {:ok, %Link{} = link} = Shortener.create_link(valid_attrs)
      assert link.title == "some title"
      assert link.original_url == "some original_url"
      assert link.slug == "some slug"
      assert link.view_count == 42
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shortener.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      update_attrs = %{title: "some updated title", original_url: "some updated original_url", slug: "some updated slug", view_count: 43}

      assert {:ok, %Link{} = link} = Shortener.update_link(link, update_attrs)
      assert link.title == "some updated title"
      assert link.original_url == "some updated original_url"
      assert link.slug == "some updated slug"
      assert link.view_count == 43
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Shortener.update_link(link, @invalid_attrs)
      assert link == Shortener.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Shortener.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Shortener.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Shortener.change_link(link)
    end
  end
end
