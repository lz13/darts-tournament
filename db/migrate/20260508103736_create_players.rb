class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players, id: :uuid do |t|
      t.string :name, null: false
      t.integer :seed_number
      t.references :tournament, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :players, [ :tournament_id, :seed_number ], unique: true
  end
end
