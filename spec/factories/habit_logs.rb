FactoryBot.define do
  factory :habit_log do
    association :habit
    date { Date.current }
    completed { true }
  end
end
