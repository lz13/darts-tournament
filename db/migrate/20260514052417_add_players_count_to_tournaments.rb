class AddPlayersCountToTournaments < ActiveRecord::Migration[8.1]
  def change
    add_column :tournaments, :players_count, :integer, default: 0, null: false

    # Backfill existing data using raw SQL
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE tournaments
          SET players_count = (
              SELECT COUNT(*)
              FROM players
              WHERE players.tournament_id = tournaments.id
          )
          WHERE EXISTS (
              SELECT 1
              FROM players
              WHERE players.tournament_id = tournaments.id
          )
        SQL
      end
    end
  end
end
