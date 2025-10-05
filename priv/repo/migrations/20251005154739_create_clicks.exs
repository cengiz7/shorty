defmodule Shorty.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks) do
      add :timestamp, :naive_datetime
      add :ip_address, :string
      add :user_agent, :text
      add :referrer, :text
      add :link_id, references(:links, on_delete: :delete_all)

      timestamps()
    end

    create index(:clicks, [:link_id])
  end
end