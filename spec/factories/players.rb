FactoryBot.define do
  factory :player do
    tournament

    sequence(:name) { |n| "Player #{n}" }
    seed_number { nil }

    trait :seeded do
      sequence(:seed_number) { |n| n }
    end
  end
end
