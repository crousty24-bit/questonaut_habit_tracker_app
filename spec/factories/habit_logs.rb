FactoryBot.define do
  factory :habit_log do
    association :habit
    validated_on { Date.current }
    streak_days { 1 }

    after(:create) do |habit_log|
      habit_log.habit.recalculate_streaks!
      habit_log.reload
    end
  end
end
