# Double Elimination Bracket Logic

## How It Works

1. **Winner Bracket**: All players start here. Win -> advance. Lose -> drop to the loser bracket
2. **Loser Bracket**: Second chance. Win -> advance. Lose -> eliminated (2 losses total)
3. **Grand Final**: Winners bracket champion vs. Losers bracket champion
4. **Reset Match**: If the winner bracket champion wins, they are the tournament champion. If the loser bracket champion wins, a reset match is played to determine the true champion (since the winner bracket champion would only have 1 loss at that point).
---
## Bracket Size & Byes

Player count is rounded up to the nearest power of 2. Higher seeds receive byes (auto-advance to round 2)

| Players | Bracket Size | Byes | Who Gets Byes       |
|---------|--------------|------|---------------------|
| 2       | 2            | 0    | -                   |
| 3       | 4            | 1    | Seed 1              |
| 4       | 4            | 0    | -                   |
| 5       | 8            | 3    | Seeds 1, 2, 3       |
| 6       | 8            | 2    | Seeds 1, 2          |        
| 7       | 8            | 1    | Seed 1              |
| 8       | 8            | 0    | -                   |
| 9-16    | 16           | 7-0  | Top seeds as needed |
---
## Seeding Methods

- **Ordered**: Seeds assigned 1, 2, 3... in order players were added
- **Random**: Seeds randomly shuffled when the tournament starts
- **Manual**: Organizer assigns each player's seed number before starting
---
## Standard Seeding Matchups

For an 8-player bracket:

Winners Round 1:
- Match 1: Seed 1 vs. Seed 8
- Match 2: Seed 4 vs. Seed 5
- Match 3: Seed 2 vs. Seed 7
- Match 4: Seed 3 vs. Seed 6

This structure ensures:
- The top seeds are on opposite sides of the bracket
- Higher seeds only meet in later rounds
- Upsets are required for lower seeds to advance deep
---
## Match Flow
- Losers from Winners R1 drop to Losers R1
- Losers from Winners R2 drop to Losers R2 (or later)
- Grand Final: Winners Champion vs. Losers Champion. If Loser Champion wins, a reset match is played to determine the true champion (since Winner Champion would only have 1 loss at that point).