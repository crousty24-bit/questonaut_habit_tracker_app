FactoryBot.define do
  factory :badge do
    sequence(:name) { |n| "Badge #{n}" }
    description { Faker::Lorem.sentence(word_count: 6) }
    icon { nil }
    image_key { nil }
  end
end
