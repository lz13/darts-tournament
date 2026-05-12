FactoryBot.define do
  factory :match do
    tournament
    bracket_type { "unassigned" }
    round_number { 1 }
    position { 1 }
    status { "pending" }

    trait :ready do
      status { "ready" }
      association :player_one, factory: :player, tournament: tournament
      association :player_two, factory: :player, tournament: tournament
    end

    trait :completed do
      status { "completed" }
      association :player_one, factory: :player, tournament: tournament
      association :player_two, factory: :player, tournament: tournament
      association :winner, factory: :player, tournament: tournament
      player_one_score { 2 }
      player_two_score { 1 }
    end

    trait :bye do
      player_one { nil }
      player_two { nil }
    end
  end
end
