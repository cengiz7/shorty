defmodule Shorty.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :original_url, :string
      add :slug, :string
      add :title, :string
      add :view_count, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:links, [:slug])
  end
end
