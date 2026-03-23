FactoryBot.define do
  factory :tag do
    association :habit
    title { "health" }
  end
end
