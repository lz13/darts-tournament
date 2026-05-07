# Database Schema
## tournaments
| Column         | Type     | Notes                                          |
|----------------|----------|------------------------------------------------|
| id             | bigint   | primary key                                    |
| name           | string   | required, max 100 chars                        |
| status         | string   | draft, in_progress, completed (default: draft) |
| format         | string   | double_elimination (default)                   |
| share_token    | string   | public URL token (unique, indexed)             |
| admin_token    | string   | admin URL token (unique, indexed)              |
| legs_to_win    | integer  | default 3 (best of 5)                          |
| seeding_method | string   | ordered, manual, random (default: ordered)     |
| created_at     | datetime |                                                |
| updated_at     | datetime |                                                |
## players
| Column        | Type     | Notes                             |
|---------------|----------|-----------------------------------|
| id            | bigint   | primary key                       |
| tournament_id | bigint   | foreign key, indexed              |
| name          | string   | required, max 50 chars            |
| seed_number   | integer  | bracket seeding (1 = top seed)    |
| created_at    | datetime |                                   |
| updated_at    | datetime |                                   |
## matches
| Column              | Type     | Notes                                      |
|---------------------|----------|--------------------------------------------|
| id                  | bigint   | primary key                                |
| tournament_id       | bigint   | foreign key, indexed                       |
| player1_id          | bigint   | foreign key to players (nullable for TBD)  |
| player2_id          | bigint   | foreign key to players (nullable)          |
| winner_id           | bigint   | foreign key to players (nullable)          |
| player1_score       | integer  | legs won (nullable)                        |
| player2_score       | integer  | legs won (nullable)                        |
| bracket_type        | string   | winners, losers, grand_final               |
| round_number        | integer  | round within bracket (1-indexed)           |
| position            | integer  | slot position within round (1-indexed)     |
| status              | string   | pending, ready, in_progress, completed     |
| next_match_id       | bigint   | self-ref FK (winner advances here)         |
| loser_next_match_id | bigint   | self-ref FK (loser drops here, nullable)   |
| created_at          | datetime |                                            |
| updated_at          | datetime |                                            |
## indexes
- `tournaments.share_token` (unique)
- `tournaments.admin_token` (unique)
- `players.tournament_id`
- `matches.tournament_id`
- `matches.next_match_id`
- `matches.loser_next_match_id`
---