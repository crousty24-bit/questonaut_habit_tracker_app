require "rails_helper"

RSpec.describe "Pages views", type: :view do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
    stub_validation_helpers
  end

  describe "pages/home" do
    it "shows the landing hero for guests" do
      stub_guest_user

      render template: "pages/home"

      expect(parsed_html).to have_text("Become the")
      expect(parsed_html).to have_text("Commander")
      expect(parsed_html).to have_text("of Your Habits")
      expect(parsed_html).to have_link("Launch Mission", href: new_user_session_path)
      expect(parsed_html).to have_link("Explore", href: new_user_registration_path)
      expect(parsed_html).to have_text("Mission Dashboard")
    end

    it "points signed-in users to the dashboard" do
      user = create(:user)
      stub_signed_in_user(user)

      render template: "pages/home"

      expect(parsed_html).to have_link("Launch Mission", href: dashboard_path)
      expect(parsed_html).to have_link("Explore", href: dashboard_path)
    end
  end

  describe "pages/dashboard" do
    it "wraps the dashboard content in a turbo frame" do
      user = create(:user, login_streak: 4, xp_total: 40, xp: 40, level: 1)
      habit = create(:habit, user: user, title: "Morning Stretch", category_name: "fitness")
      assign_dashboard_state(user: user, habits: [habit])
      stub_signed_in_user(user, current_path: dashboard_path)

      render template: "pages/dashboard"

      expect(rendered).to include('turbo-frame id="dashboard_content"')
      expect(parsed_html).to have_text("Welcome Back Commander")
      expect(parsed_html).to have_text("Morning Stretch")
    end
  end

  describe "pages/_dashboard_content" do
    it "shows the empty state when there are no missions" do
      user = create(:user, login_streak: 1)
      assign_dashboard_state(user: user, habits: [])
      stub_signed_in_user(user, current_path: dashboard_path)

      render partial: "pages/dashboard_content"

      expect(parsed_html).to have_text("Aucune mission active")
      expect(parsed_html).to have_button("New Mission")
      expect(parsed_html).not_to have_text("Recent Badges")
    end

    it "shows mission cards in the cockpit terminal when missions exist" do
      user = create(:user, login_streak: 5, xp_total: GamifiedXp.xp_threshold_for_level(2) + 20, xp: 20, level: 2)
      daily_habit = create(:habit, user: user, title: "Hydrate", category_name: "nutrition", frequency: "daily")
      weekly_habit = create(:habit, :weekly, user: user, title: "Weekly Review", category_name: "productivity")
      create(:habit_log, habit: daily_habit, validated_on: Date.current)
      assign_dashboard_state(user: user, habits: [daily_habit, weekly_habit])
      stub_signed_in_user(user, current_path: dashboard_path)

      render partial: "pages/dashboard_content"

      expect(parsed_html).to have_text("Mission Terminal")
      expect(parsed_html).to have_text("Quest Logs")
      expect(parsed_html).to have_text("Hydrate")
      expect(parsed_html).to have_text("Weekly Review")
      expect(parsed_html).to have_button("COMPLÉTÉE", disabled: true)
      expect(parsed_html).to have_button("MODIFIER")
    end
  end

  describe "pages/terms" do
    it "renders the terms sections and legal links" do
      stub_guest_user

      render template: "pages/terms"

      expect(parsed_html).to have_text("Terms of Use")
      expect(parsed_html).to have_text("Legal notice")
      expect(parsed_html).to have_link("Cookies", href: cookies_path)
      expect(view.content_for(:title)).to eq("Terms of Use - Questonaut")
    end
  end

  describe "pages/cookies" do
    it "renders the cookie policy and controls" do
      stub_guest_user

      render template: "pages/cookies"

      expect(parsed_html).to have_text("Cookie Policy")
      expect(parsed_html).to have_button("Reset my choice")
      expect(parsed_html).to have_link("Back to home", href: root_path)
      expect(view.content_for(:title)).to eq("Cookie Policy - Questonaut")
    end
  end
end
