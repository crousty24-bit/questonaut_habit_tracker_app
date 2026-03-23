FactoryBot.define do
  factory :habit do
    association :user
    sequence(:title) { |n| "Mission #{n}" }
    description { Faker::Lorem.sentence(word_count: 5) }
    frequency { "daily" }
    category_name { "health" }

    trait :weekly do
      frequency { "weekly" }
    end
  end
end
