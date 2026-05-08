class CreateTournaments < ActiveRecord::Migration[8.1]
  def change
    create_table :tournaments, id: :uuid do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "draft"
      t.string :format, null: false, default: "double_elimination"
      t.string :share_token, null: false
      t.string :admin_token, null: false
      t.integer :legs_to_win, null: false, default: 3
      t.string :seeding_method, null: false, default: "ordered"

      t.timestamps
    end

    add_index :tournaments, :share_token, unique: true
    add_index :tournaments, :admin_token, unique: true
    add_index :tournaments, :status
    add_index :tournaments, :format
  end
end
