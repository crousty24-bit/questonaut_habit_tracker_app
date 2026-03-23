require "rails_helper"

RSpec.describe "Badges views", type: :view do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
    stub_guest_user
  end

  describe "badges/index" do
    it "renders the statistics overview and badge collection frame" do
      user = create(:user)
      habits = [
        create(:habit, user: user, title: "Read", category_name: "learning"),
        create(:habit, user: user, title: "Workout", category_name: "fitness")
      ]

      assign(:habits, habits)
      assign(:success_rate, 75)
      assign(:mission_days, 5)
      assign(:best_streak, 4)
      assign(:unlocked_badges_count, 2)
      assign(:total_badges_count, 6)
      assign(:category_distribution, { "learning" => 1, "fitness" => 1 })
      assign(:weekly_progress, [
        { label: "Lundi", value: 10, height_percent: 20 },
        { label: "Mardi", value: 20, height_percent: 40 },
        { label: "Mercredi", value: 30, height_percent: 60 },
        { label: "Jeudi", value: 0, height_percent: 0 },
        { label: "Vendredi", value: 10, height_percent: 20 },
        { label: "Samedi", value: 0, height_percent: 0 },
        { label: "Dimanche", value: 0, height_percent: 0 }
      ])
      assign(:detailed_habits, habits)

      render template: "badges/index"

      expect(parsed_html).to have_text("Mission Report")
      expect(parsed_html).to have_text("75%")
      expect(parsed_html).to have_text("Badge Collection")
      expect(parsed_html).to have_css("turbo-frame#statistics_badge_collection")
    end
  end

  describe "badges/show" do
    it "renders the badge details and back link" do
      badge = create(:badge, name: "Welcome", description: "First login badge")
      assign(:badge, badge)
      assign(:notice, "Saved")

      render template: "badges/show"

      expect(parsed_html).to have_text("Welcome")
      expect(parsed_html).to have_text("First login badge")
      expect(parsed_html).to have_link("Back to statistics", href: statistics_path)
    end
  end

  describe "badges/_badge_collection" do
    it "renders unlocked and locked badge groups" do
      unlocked_badge = create(:badge, name: "Welcome")
      locked_badge = create(:badge, name: "Level 5")
      assign(:badges, [unlocked_badge, locked_badge])
      assign(:unlocked_badges_count, 1)
      assign(:user_badge_ids, [unlocked_badge.id])
      assign(:badge_groups, {
        "Mission Milestones" => [unlocked_badge],
        "Level Ranks" => [locked_badge]
      })

      render partial: "badges/badge_collection"

      expect(parsed_html).to have_text("Badge Collection")
      expect(parsed_html).to have_text("Mission Milestones")
      expect(parsed_html).to have_text("Level Ranks")
      expect(parsed_html).to have_text("Welcome")
      expect(parsed_html).to have_text("Level 5")
    end
  end

  describe "badges/_badge" do
    it "renders the badge fields" do
      badge = create(:badge, name: "Explorer", description: "Badge description")

      render partial: "badges/badge", locals: { badge: badge }

      expect(parsed_html).to have_text("Explorer")
      expect(parsed_html).to have_text("Badge description")
    end
  end
end
