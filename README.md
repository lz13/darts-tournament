# Darts Tournament Manager (DTM)

A Ruby on Rails application for managing darts tournaments with double elimination brackets.

---

## Features

- Create casual local tournaments (no user accounts required)
- Add unlimited players by name
- Choose a seeding method (ordered, manual, or random)
- Auto-generate double elimination brackets with proper bye handling
- Enter match scores and auto-advance winners/losers
- Public shareable tournament links
- Real-time bracket updates via Turbo Streams
- Mobile-friendly responsive design

---

## Tech Stack

- **Ruby** 4.0.2
- **Rails** 8.1.2
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: PostgreSQL
- **Testing**: RSpec, FactoryBot, Shoulda Matchers

---
## Getting Started

### Prerequisites

- Ruby 4.0.2
- Rails 8.1.2
- PostgreSQL 14+
- Node.js 18+

---

## Installation

```bash
git clone https://github.com/lz13/darts-tournament.git
cd darts-tournament
bundle install
bin/rails db:create db:migrate
bin/dev

Visit http://localhost:3000 in your browser.
```

### Running Tests
```bash
bundle exec rspec
```

### URL Structure

| Path                               | Purpose                            |
|------------------------------------|------------------------------------|
| /                                  | Home Page                          |
| /tournaments/new                   | Create a new tournament            |
| /t/:share_token                    | Public tournament view (read-only) |
| /t/:share_token/admin/:admin_token | Admin tournament view              |

### Documentation
- [Implementation Checklist](docs/CHECKLIST.md) - Development roadmap and progress
- [Database Schema](docs/DATABASE_SCHEMA.md) - Models and table structures
- [Double Elimination Logic](docs/DOUBLE_ELIMINATION.md) - Bracket rules, seeding, and byes
- [Color Palette](docs/COLOR_PALETTE.md) - UI design system colors
- [Commands Reference](docs/COMMANDS.md) - Useful development commands

### Future Enhancements

- User accounts and authentication
- Player profiles and statistics
- Single elimination, group stages, round robins, and other tournament formats
- Bracket reset in grand final (true double elimination)
- Live leg-by-leg scoring (301/501)
- Printable bracket view (PDF export)
- Real-time spectator updates via ActionCable

---
