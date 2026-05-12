FactoryBot.define do
  factory :match do
    tournament
    bracket_type { "unassigned" }
    round_number { 1 }
    position { 1 }
    status { "pending" }

    trait :ready do
      status { "ready" }
      player_one { association(:player, tournament: tournament) }
      player_two { association(:player, tournament: tournament) }
    end

    trait :completed do
      status { "completed" }
      player_one { association(:player, tournament: tournament) }
      player_two { association(:player, tournament: tournament) }
      winner { player_one }
      player_one_score { 2 }
      player_two_score { 1 }
    end

    trait :bye do
      player_one { nil }
      player_two { nil }
    end
  end
end
