class BracketGenerator
  def initialize(tournament)
    @tournament = tournament
    @players = tournament.players.order(:seed_number).to_a
    @bracket_size = next_power_of_two([ @players.size, 2 ].max)
    @created_matches = {}
  end
  def generate!
    ActiveRecord::Base.transaction do
      @tournament.matches.destroy_all
      create_winner_bracket!
      create_loser_bracket!
      create_grand_final!
      assign_byes!
      set_initial_ready_status!
    end
  end
  private
  def next_power_of_two(n)
    2 ** Math.log2(n).ceil
  end
  def seeding_matchups(size)
    case size
    when 2
      [ [ 1, 2 ] ]
    when 4
      [ [ 1, 4 ], [ 2, 3 ] ]
    when 8
      [ [ 1, 8 ], [ 4, 5 ], [ 2, 7 ], [ 3, 6 ] ]
    when 16
      [ [ 1, 16 ], [ 8, 9 ], [ 4, 13 ], [ 5, 12 ], [ 2, 15 ], [ 7, 10 ], [ 3, 14 ], [ 6, 11 ] ]
    else
      raise ArgumentError, "Unsupported bracket size: #{size}"
    end
  end
  def create_winner_bracket!
    total_rounds = Math.log2(@bracket_size).to_i

    (1..total_rounds).each do |round|
      match_count = @bracket_size / (2 ** round)

      (1..match_count).each do |position|
        match = create_match(bracket_type: "winners", round_number: round, position: position)
        key = "wb_r#{round}_m#{position}"
        @created_matches[key] = match

        if round > 1
          prev_1 = @created_matches["wb_r#{round - 1}_m#{(position * 2) - 1}"]
          prev_2 = @created_matches["wb_r#{round - 1}_m#{position * 2}"]
          prev_1.update!(winner_next_match: match) if prev_1
          prev_2.update!(winner_next_match: match) if prev_2
        end
      end
    end
  end
  def create_loser_bracket!
    return if @bracket_size <= 2

    total_lb_rounds = (Math.log2(@bracket_size).to_i * 2) - 2
    wb_final_round = Math.log2(@bracket_size).to_i

    # Build LB round by round with known structure
    previous_lb_matches = []

    (1..total_lb_rounds).each do |round|
      # Determine how many matches in this LB round
      if round == 1
        # First round: WB R1 losers
        wb_r1 = @created_matches.select { |k, _| k.start_with?("wb_r1_") }.values
        match_count = wb_r1.size / 2
      elsif round == total_lb_rounds
        # LB Final: 1 match
        match_count = 1
      elsif round.odd?
        # Odd rounds after 1: consolidation rounds (fewer matches)
        match_count = previous_lb_matches.size / 2
      else
        # Even rounds: feed rounds (same size as previous)
        match_count = previous_lb_matches.size
      end

      current_matches = []

      (1..match_count).each do |position|
        match = create_match(bracket_type: "losers", round_number: round, position: position)
        current_matches << match
        @created_matches["lb_r#{round}_m#{position}"] = match
      end

      # Link previous LB round winners
      previous_lb_matches.each_with_index do |prev_match, i|
        target = current_matches[i / 2] || current_matches.last
        prev_match.update!(winner_next_match: target) if target
      end

      # Link WB losers (even rounds, not final)
      if round.even? && round < total_lb_rounds
        wb_round = round / 2
        wb_matches = @created_matches.select { |k, _| k.start_with?("wb_r#{wb_round}_") }.values
        wb_matches.each_with_index do |wb_match, i|
          target = current_matches[i] || current_matches.last
          wb_match.update!(loser_next_match: target) if target && wb_match.loser_next_match.nil?
        end
      end

      previous_lb_matches = current_matches
    end

    # LB Final
    lb_final = create_match(bracket_type: "losers", round_number: total_lb_rounds + 1, position: 1)
    @created_matches["lb_final"] = lb_final

    last_lb = previous_lb_matches.last
    last_lb.update!(winner_next_match: lb_final) if last_lb

    wb_final = @created_matches.select { |k, _| k.start_with?("wb_r#{wb_final_round}_") }.values.first
    wb_final.update!(loser_next_match: lb_final) if wb_final
  end
  def create_grand_final!
    wb_final_round = Math.log2(@bracket_size).to_i
    wb_final = @created_matches.select { |k, _| k.start_with?("wb_r#{wb_final_round}_") }.values.first
    lb_final = @created_matches["lb_final"]

    gf1 = create_match(bracket_type: "grand_final", round_number: 1, position: 1)
    @created_matches["gf1"] = gf1

    wb_final.update!(winner_next_match: gf1) if wb_final
    lb_final.update!(winner_next_match: gf1) if lb_final

    gf2 = create_match(bracket_type: "grand_final", round_number: 2, position: 1)
    @created_matches["gf2"] = gf2
    gf1.update!(winner_next_match: gf2)
  end
  def assign_byes!
    # Get first round WB matches
    wb_r1_matches = @created_matches.select { |k, _| k.start_with?("wb_r1_") }.values

    # Assign players to first round based on seeding
    matchups = seeding_matchups(@bracket_size)

    matchups.each_with_index do |matchup, index|
      match = wb_r1_matches[index]
      next unless match

      if matchup[0] <= @players.size
        match.update!(player_one: @players[matchup[0] - 1])
      end
      if matchup[1] <= @players.size
        match.update!(player_two: @players[matchup[1] - 1])
      end
    end

    # Skip bye handling if no byes needed
    return if @players.size >= @bracket_size

    # Auto-advance bye players
    wb_r1_matches.each do |match|
      if match.player_one.present? && match.player_two.nil?
        advance_bye_winner(match, match.player_one)
      elsif match.player_one.nil? && match.player_two.present?
        advance_bye_winner(match, match.player_two)
      end
    end
  end
  def advance_bye_winner(match, winner)
    match.update!(winner: winner, status: "completed", player_one_score: 0, player_two_score: 0)

    if match.winner_next_match
      next_match = match.winner_next_match
      if next_match.player_one.nil?
        next_match.update!(player_one: winner)
      elsif next_match.player_two.nil?
        next_match.update!(player_two: winner)
      end
    end
  end
  def set_initial_ready_status!
    @created_matches.each do |_, match|
      next if match.status == "completed"
      match.update!(status: "ready") if match.players_assigned?
    end
  end
  def create_match(bracket_type:, round_number:, position:)
    @tournament.matches.create!(
      bracket_type: bracket_type,
      round_number: round_number,
      position: position,
      status: "pending"
    )
  end
end
