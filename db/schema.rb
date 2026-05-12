# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_11_114623) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bracket_type", default: "unassigned", null: false
    t.datetime "created_at", null: false
    t.uuid "loser_next_match_id"
    t.uuid "player_one_id"
    t.integer "player_one_score"
    t.uuid "player_two_id"
    t.integer "player_two_score"
    t.integer "position", null: false
    t.integer "round_number", null: false
    t.string "status", default: "pending", null: false
    t.uuid "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "winner_id"
    t.uuid "winner_next_match_id"
    t.index ["loser_next_match_id"], name: "index_matches_on_loser_next_match_id"
    t.index ["player_one_id"], name: "index_matches_on_player_one_id"
    t.index ["player_two_id"], name: "index_matches_on_player_two_id"
    t.index ["tournament_id", "bracket_type", "round_number", "position"], name: "index_metches_on_tournament_bracket_round_position", unique: true
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
    t.index ["winner_next_match_id"], name: "index_matches_on_winner_next_match_id"
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "seed_number"
    t.uuid "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id", "seed_number"], name: "index_players_on_tournament_id_and_seed_number", unique: true
    t.index ["tournament_id"], name: "index_players_on_tournament_id"
  end

  create_table "tournaments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "admin_token", null: false
    t.datetime "created_at", null: false
    t.string "format", default: "double_elimination", null: false
    t.integer "legs_to_win", default: 3, null: false
    t.string "name", null: false
    t.string "seeding_method", default: "ordered", null: false
    t.string "share_token", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_token"], name: "index_tournaments_on_admin_token", unique: true
    t.index ["format"], name: "index_tournaments_on_format"
    t.index ["share_token"], name: "index_tournaments_on_share_token", unique: true
    t.index ["status"], name: "index_tournaments_on_status"
  end

  add_foreign_key "matches", "matches", column: "loser_next_match_id"
  add_foreign_key "matches", "matches", column: "winner_next_match_id"
  add_foreign_key "matches", "players", column: "player_one_id"
  add_foreign_key "matches", "players", column: "player_two_id"
  add_foreign_key "matches", "players", column: "winner_id"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "players", "tournaments"
end
