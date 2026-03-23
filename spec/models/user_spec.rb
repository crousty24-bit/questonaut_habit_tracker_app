require "rails_helper"

RSpec.describe User do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe "validations" do
    it "rejects a forbidden commander name" do
      user = User.new(
        name: "admin pilot",
        email: "pilot@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).not_to be_valid
      expect(user.errors.details[:name]).to include(hash_including(error: :forbidden_content))
    end

    it "rejects an invalid email address" do
      user = User.new(
        name: "Pilot Vega",
        email: "not-an-email",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user).not_to be_valid
      expect(user.errors.of_kind?(:email, :invalid)).to be(true)
    end
  end

  describe "#update_login_streak" do
    it "updates the streak only once per day" do
      user = create_user(email: "streak@example.com", login_streak: 0, last_daily_login: nil)

      travel_to(Date.new(2026, 3, 19)) do
        expect(user.update_login_streak).to be(true)
        expect(user.reload.login_streak).to eq(1)

        expect(user.update_login_streak).to be(false)
        expect(user.reload.login_streak).to eq(1)
      end
    end
  end

  describe "#add_xp" do
    it "awards every configured level milestone when the user reaches them" do
      Badge::LEVEL_IMAGE_KEYS.each_key do |level|
        Badge.create!(name: "Level #{level}")
      end

      user = create_user(email: "levels@example.com")

      user.add_xp(24_900)

      expect(user.reload.level).to eq(250)
      expect(user.badges.where("name LIKE ?", "Level %").pluck(:name)).to match_array(
        Badge::LEVEL_IMAGE_KEYS.keys.map { |level| "Level #{level}" }
      )
    end
  end

  describe "#award_daily_login" do
    it "awards the Welcome badge on the first login day" do
      Badge.create!(name: "Welcome")
      user = create_user(email: "welcome-login@example.com", login_streak: 0, last_daily_login: nil)

      travel_to(Date.new(2026, 3, 19)) do
        user.award_daily_login

        expect(user.reload.login_streak).to eq(1)
        expect(user.badges.pluck(:name)).to include("Welcome")
      end
    end

    it "awards the 30-day login badge and Veteran badge at the right milestones" do
      Badge.create!(name: "Daily Login")
      Badge.create!(name: "Veteran")

      travel_to(Date.new(2026, 3, 19)) do
        user = create_user(
          email: "daily-login@example.com",
          login_streak: 29,
          last_daily_login: Date.current - 1.day
        )
        user.update_column(:created_at, 7.months.ago)

        user.award_daily_login

        expect(user.reload.login_streak).to eq(30)
        expect(user.badges.pluck(:name)).to include("Daily Login", "Veteran")
      end
    end
  end
end
