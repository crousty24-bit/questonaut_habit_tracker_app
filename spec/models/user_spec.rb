require "rails_helper"

RSpec.describe User do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe "associations" do
    subject(:user) { build(:user) }

    it { is_expected.to have_many(:habits).dependent(:destroy) }
    it { is_expected.to have_many(:user_badges).dependent(:destroy) }
    it { is_expected.to have_many(:badges).through(:user_badges) }
  end

  describe "validations" do
    subject(:user) { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(15) }
    it { is_expected.to allow_value("pilot@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }

    it "rejects a forbidden commander name" do
      user.name = "admin pilot"

      expect(user).not_to be_valid
      expect(user.errors.details[:name]).to include(hash_including(error: :forbidden_content))
    end
  end

  describe "#update_login_streak" do
    it "updates the streak only once per day" do
      user = create(:user, email: "streak@example.com", login_streak: 0, last_daily_login: nil)

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
        create(:badge, name: "Level #{level}")
      end

      user = create(:user, email: "levels@example.com")

      user.add_xp(GamifiedXp.xp_threshold_for_level(Badge::LEVEL_IMAGE_KEYS.keys.max))

      expect(user.reload.level).to eq(Badge::LEVEL_IMAGE_KEYS.keys.max)
      expect(user.badges.where("name LIKE ?", "Level %").pluck(:name)).to match_array(
        Badge::LEVEL_IMAGE_KEYS.keys.map { |level| "Level #{level}" }
      )
    end

    it "supports multiple level ups from a single XP gain" do
      user = create(:user, email: "multi-level@example.com")
      xp_gain = 600

      user.add_xp(xp_gain)

      expect(user.reload.level).to eq(GamifiedXp.level_from_total_xp(xp_gain))
      expect(user.xp_total).to eq(xp_gain)
      expect(user.xp).to eq(GamifiedXp.xp_within_level(xp_gain))
    end
  end

  describe "#xp_needed_for_current_level" do
    it "uses the rebalanced early-game progression curve" do
      user = build(:user, level: 1)

      expect(user.xp_needed_for_current_level).to eq(49)

      user.level = 2

      expect(user.xp_needed_for_current_level).to eq(67)
    end
  end

  describe "#recalc_level_from_total_xp" do
    it "rebuilds level and in-level XP from the cumulative total" do
      user = build(:user, xp_total: 600, level: 1, xp: 0)

      user.recalc_level_from_total_xp

      expect(user.level).to eq(GamifiedXp.level_from_total_xp(600))
      expect(user.xp).to eq(GamifiedXp.xp_within_level(600))
    end
  end

  describe "BadgeAwarder integration" do
    it "triggers badge awarding when a level changes" do
      user = create(:user, email: "badge-awarder-integration@example.com")
      allow(BadgeAwarder).to receive(:call)

      user.add_xp(user.xp_needed_for_current_level)

      expect(BadgeAwarder).to have_received(:call).with(user, context: :level_up)
    end
  end

  describe "#award_daily_login" do
    it "awards the Welcome badge on the first login day" do
      create(:badge, name: "Welcome")
      user = create(:user, email: "welcome-login@example.com", login_streak: 0, last_daily_login: nil)

      travel_to(Date.new(2026, 3, 19)) do
        user.award_daily_login

        expect(user.reload.login_streak).to eq(1)
        expect(user.badges.pluck(:name)).to include("Welcome")
      end
    end

    it "awards the 30-day login badge and Veteran badge at the right milestones" do
      create(:badge, name: "Daily Login")
      create(:badge, name: "Veteran")

      travel_to(Date.new(2026, 3, 19)) do
        user = create(
          :user,
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
