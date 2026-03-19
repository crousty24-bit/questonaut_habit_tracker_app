require "rails_helper"

RSpec.describe User do
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
end
