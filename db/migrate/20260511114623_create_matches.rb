class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches, id: :uuid do |t|
      t.references :tournament, type: :uuid, null: false, foreign_key: true
      t.references :player_one, type: :uuid, null: true, foreign_key: {  to_table: :players }
      t.references :player_two, type: :uuid, null: true, foreign_key: {  to_table: :players }
      t.references :winner, type: :uuid, null: true, foreign_key: {  to_table: :players }
      t.integer :player_one_score
      t.integer :player_two_score
      t.string :bracket_type, null: false, default: "unassigned"
      t.integer :round_number, null: false
      t.integer :position, null: false
      t.string :status, null: false, default: "pending"

      t.references :winner_next_match, type: :uuid, null: true,  foreign_key: {  to_table: :matches }
      t.references :loser_next_match, type: :uuid, null: true, foreign_key: { to_table: :matches }

      t.timestamps
    end

    add_index :matches, [ :tournament_id, :bracket_type, :round_number, :position ], unique: true, name: "index_matches_on_tournament_bracket_round_position"
  end
end
