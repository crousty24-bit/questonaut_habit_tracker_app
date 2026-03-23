FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "commander#{n}@example.com" }
    sequence(:name) { |n| "Cmdr#{n}" }
    password { TestDataHelpers::DEFAULT_PASSWORD }
    password_confirmation { password }
    terms_accepted { "1" }
    total_xp { 0 }
    level { 1 }
    login_streak { 0 }
    last_daily_login { nil }
  end
end
