FactoryBot.define do
  factory :tournament do
    sequence(:name) { |n| "Tournament #{n}" }
    status { "draft" }
    format { "double_elimination" }
    # share_token { "MyString" }
    # admin_token { "MyString" }
    legs_to_win { 3 }
    seeding_method { "ordered" }

    trait :in_progress do
      status { "in_progress" }
    end

    trait :completed do
      status { "completed" }
    end
  end
end
