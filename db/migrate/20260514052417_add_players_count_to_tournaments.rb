class AddPlayersCountToTournaments < ActiveRecord::Migration[8.1]
  def change
    add_column :tournaments, :players_count, :integer, default: 0, null: false

    # Backfill existing data
    reversible do |dir|
      dir.up do
        Tournament.find_each do |tournament|
          Tournament.reset_counters(tournament.id, :players)
        end
      end
    end
  end
end
