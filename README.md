# Darts Tournament Manager (DTM)
A Ruby on Rails application for managing darts tournaments with double elimination brackets. Built with Rails 8, Hotwire (Turbo + Stimulus), and Tailwind CSS.
## Features (MVP)
- Create casual local tournaments (no user accounts required)
- Add unlimited players by name
- Choose seeding method (ordered, manual, or random)
- Auto-generate double elimination brackets with proper bye handling
- Enter match scores and auto-advance winners/losers
- Public shareable tournament links
- Real-time bracket updates via Turbo Streams
- Mobile-friendly responsive design
## Tech Stack
- Ruby 4.0.2
- Rails 8.1.2
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- PostgreSQL
- RSpec for testing
---
## Implementation Checklist
### Phase 1: Project Setup
- [x] Create new Rails 8 app with PostgreSQL, Tailwind, and Hotwire
- [x] Add and configure RSpec with FactoryBot and Shoulda Matchers
- [x] Configure database (create development and test databases)
- [x] Add .mise.toml for mise version management
- [ ] Set up basic application layout with Tailwind (mobile-first)
- [ ] Add a styled home page with "Create Tournament" button
- [ ] Verify Turbo/Stimulus are working (quick test)
- [ ] Verify setup: bin/dev runs, RSpec works, Stimulus loads
### Phase 2: Core Models
- [ ] Generate Tournament model
  - name (string, required)
  - status (string, default: "draft")
  - format (string, default: "double_elimination")
  - share_token (string, unique)
  - admin_token (string, unique)
  - legs_to_win (integer, default: 3)
  - seeding_method (string, default: "ordered")
- [ ] Generate Player model
  - tournament_id (references)
  - name (string, required)
  - seed_number (integer)
- [ ] Generate Match model
  - tournament_id (references)
  - player1_id, player2_id, winner_id (references to players)
  - player1_score, player2_score (integers)
  - bracket_type (string: winners/losers/grand_final)
  - round_number, position (integers)
  - status (string, default: "pending")
  - next_match_id, loser_next_match_id (self-references)
- [ ] Add model associations and validations
- [ ] Add secure token generation callbacks for Tournament
- [ ] Add database indexes for foreign keys and tokens
- [ ] Write model specs
### Phase 3: Tournament Management
- [ ] Generate Tournaments controller
- [ ] Routes: root, /tournaments/new, /tournaments (POST)
- [ ] Routes: /t/:share_token (public view)
- [ ] Routes: /t/:share_token/admin/:admin_token (admin view)
- [ ] New tournament form (name, legs_to_win, seeding_method dropdown)
- [ ] Show action with share_token lookup
- [ ] Admin show action with both tokens verification
- [ ] Players management (add/remove) in admin view
- [ ] Turbo Frames for dynamic player list
- [ ] Write request specs
### Phase 4: Bracket Generation Service
- [ ] Create app/services/bracket_generator.rb
- [ ] Calculate bracket size (next power of 2)
- [ ] Implement seeding strategies:
  - ordered: seeds 1,2,3... in order added
  - random: shuffle and assign seeds
  - manual: use pre-assigned seed_number
- [ ] Generate winners bracket matches
  - Standard seeding matchups (1v8, 4v5, 2v7, 3v6 for 8 players)
  - Link matches to next round (next_match_id)
- [ ] Generate losers bracket matches
  - Losers drop from winners bracket at correct rounds
  - More rounds than winners bracket
  - Link matches appropriately
- [ ] Generate grand final match
- [ ] Handle byes (auto-advance higher seeds)
- [ ] Write comprehensive service specs
### Phase 5: Bracket Visualization
- [ ] Create app/views/tournaments/_bracket.html.erb partial
- [ ] Create app/views/matches/_match_card.html.erb partial
- [ ] CSS layout with Tailwind:
  - Flexbox/Grid for bracket structure
  - Horizontal scroll container for mobile
  - Round headers
- [ ] Style match cards:
  - Player names
  - Scores (when completed)
  - Status indicator (pending/ready/in_progress/completed)
  - Winner highlight
- [ ] Color coding:
  - Winners bracket: emerald/green tones
  - Losers bracket: amber/orange tones
  - Grand final: yellow/gold accent
- [ ] Bye display (show "BYE" for empty slots)
- [ ] Responsive breakpoints
### Phase 6: Match Scoring
- [ ] Generate Matches controller (update action only)
- [ ] Score entry form in match card (admin view only)
- [ ] Stimulus controller for score validation:
  - Both scores required
  - Winner must have exactly legs_to_win
  - Loser must have less than legs_to_win
  - No ties allowed
- [ ] Match completion logic:
  - Determine winner from scores
  - Set winner_id and status = "completed"
  - Advance winner to next_match (set as player1 or player2)
  - Advance loser to loser_next_match (if exists)
  - Mark next match as "ready" when both players set
- [ ] Turbo Stream broadcasts for real-time updates
- [ ] Write request and service specs
### Phase 7: Tournament Flow & State Machine
- [ ] Add state machine to Tournament (draft → in_progress → completed)
- [ ] "Start Tournament" button in admin view
- [ ] Start tournament validations:
  - Minimum 2 players
  - Players have names
  - Manual seeding: all seeds assigned and unique
- [ ] Start tournament action:
  - Apply seeding method
  - Generate bracket
  - Change status to in_progress
  - Redirect to bracket view
- [ ] Lock player changes when not in draft status
- [ ] Tournament completion detection:
  - Grand final has a winner
  - Auto-update status to completed
- [ ] Winner announcement display
- [ ] Write integration/system specs
### Phase 8: Polish & UX
- [ ] Flash messages styling (success, error, info)
- [ ] Turbo progress bar styling
- [ ] Loading states for form submissions
- [ ] Empty states:
  - Home: "No tournaments yet"
  - Tournament: "Add players to get started"
- [ ] Error pages (404, 500) with Tailwind styling
- [ ] Share button with clipboard copy (Stimulus)
- [ ] Mobile optimizations:
  - Large touch targets for buttons
  - Score input with number keyboard
  - Sticky tournament header
- [ ] Favicon (simple dart icon or DTM letters)
- [ ] Basic meta tags for social sharing
### Phase 9: Deployment
- [ ] Review and secure production config
- [ ] Configure production database URL
- [ ] Set up RAILS_MASTER_KEY handling
- [ ] Create Dockerfile
- [ ] Create fly.toml or render.yaml
- [ ] Deploy to hosting platform
- [ ] Verify production works
- [ ] Update README with live URL
---
## Database Schema
### tournaments
| Column         | Type     | Notes                                       |
|----------------|----------|---------------------------------------------|
| id             | bigint   | primary key                                 |
| name           | string   | required, max 100 chars                     |
| status         | string   | draft, in_progress, completed (default: draft) |
| format         | string   | double_elimination (default)                |
| share_token    | string   | public URL token (unique, indexed)          |
| admin_token    | string   | admin URL token (unique, indexed)           |
| legs_to_win    | integer  | default 3 (best of 5)                       |
| seeding_method | string   | ordered, manual, random (default: ordered)  |
| created_at     | datetime |                                             |
| updated_at     | datetime |                                             |
### players
| Column        | Type     | Notes                             |
|---------------|----------|-----------------------------------|
| id            | bigint   | primary key                       |
| tournament_id | bigint   | foreign key, indexed              |
| name          | string   | required, max 50 chars            |
| seed_number   | integer  | bracket seeding (1 = top seed)    |
| created_at    | datetime |                                   |
| updated_at    | datetime |                                   |
### matches
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
---
## URL Structure
| Path                                   | Purpose                          |
|----------------------------------------|----------------------------------|
| `/`                                    | Home page, list recent tournaments |
| `/tournaments/new`                     | New tournament form              |
| `/t/:share_token`                      | Public tournament view (read-only) |
| `/t/:share_token/admin/:admin_token`   | Admin tournament view (manage)   |
---
## Getting Started
### Prerequisites
- Ruby 4.0.2
- Rails 8.1.2
- PostgreSQL 14+
- Node.js 18+ (for Tailwind/asset pipeline)
---
Double Elimination Bracket Logic
How it works:
1. Winners Bracket: All players start here. Win → advance. Lose → drop to losers bracket.
2. Losers Bracket: Second chance. Win → advance. Lose → eliminated (2 losses total).
3. Grand Final: Winners bracket champion vs Losers bracket champion.
   Bracket Size & Byes:
   Player count is rounded up to nearest power of 2. Higher seeds receive byes.
   Players	Bracket Size
   2	2
   3	4
   4	4
   5	8
   6	8
   7	8
   8	8
   9-16	16
   Seeding Methods:
- Ordered: Seeds assigned 1, 2, 3... in order players were added
- Random: Seeds randomly shuffled when tournament starts
- Manual: Organizer assigns each player's seed number before starting
  Standard Seeding Matchups (8 players):
  Winners Round 1:
  Match 1: Seed 1 vs Seed 8
  Match 2: Seed 4 vs Seed 5
  Match 3: Seed 2 vs Seed 7
  Match 4: Seed 3 vs Seed 6
  This bracket structure ensures top seeds are on opposite sides and meet only in later rounds.
---
## Commands Reference
```bash
# Start development server
bin/dev
```
```bash
# Run all tests
bundle exec rspec
```
```bash
# Run specific test file
bundle exec rspec spec/models/tournament_spec.rb

```
```bash
# Run tests with documentation format
bundle exec rspec --format documentation
```
```bash
# Generate a model
rails generate model Tournament name:string status:string
```
```bash
# Generate a controller
rails generate controller Tournaments new create show
```
```bash
# Run migrations
rails db:migrate
```
```bash
# Rails console
rails console
```
```bash
# View routes
rails routes
```
---
## Future Enhancements (Post-MVP)
- [ ] User accounts and authentication
- [ ] Player profiles and statistics tracking
- [ ] Single elimination and round robin formats
- [ ] Bracket reset in grand final (true double elimination)
- [ ] Live leg-by-leg scoring (301/501 with checkout tracking)
- [ ] Tournament history and archives
- [ ] Printable bracket view (PDF export)
- [ ] Tournament templates (save and reuse player lists)
- [ ] Real-time spectator updates via ActionCable
- [ ] Tournament scheduling (set match times)
- [ ] Multiple legs/sets format options
---