require "rails_helper"

RSpec.describe "Activity views", type: :view do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
    stub_guest_user
    stub_validation_helpers
  end

  describe "habit_logs/index" do
    it "renders nested habit log links and the dashboard back link" do
      habit = create(:habit, title: "Hydrate")
      log = create(:habit_log, habit: habit, date: Date.new(2026, 3, 23), completed: true)
      assign(:habit_logs, [log])
      assign(:notice, nil)

      render template: "habit_logs/index"

      expect(parsed_html).to have_text("Habit logs")
      expect(parsed_html).to have_text("2026-03-23")
      expect(parsed_html).to have_link("Show this habit log", href: habit_habit_log_path(habit, log))
      expect(parsed_html).to have_link("Back to dashboard", href: dashboard_path)
    end
  end

  describe "habit_logs/show" do
    it "renders the log details and nested actions" do
      habit = create(:habit, title: "Hydrate")
      log = create(:habit_log, habit: habit, date: Date.new(2026, 3, 23), completed: true)
      assign(:habit_log, log)
      assign(:notice, nil)

      render template: "habit_logs/show"

      expect(parsed_html).to have_text("Date:")
      expect(parsed_html).to have_text("Completed:")
      expect(parsed_html).to have_link("Back to habit logs", href: habit_habit_logs_path(habit))
      expect(parsed_html).to have_button("Destroy this habit log")
    end
  end

  describe "habit_logs/_habit_log" do
    it "renders the habit log fields" do
      log = create(:habit_log, date: Date.new(2026, 3, 23), completed: false)

      render partial: "habit_logs/habit_log", locals: { habit_log: log }

      expect(parsed_html).to have_text("2026-03-23")
      expect(parsed_html).to have_text("false")
      expect(parsed_html).to have_text(log.habit_id.to_s)
    end
  end

  describe "tags/index" do
    it "renders tags and the dashboard back link" do
      tag = create(:tag, title: "learning")
      assign(:tags, [tag])
      assign(:notice, nil)

      render template: "tags/index"

      expect(parsed_html).to have_text("Tags")
      expect(parsed_html).to have_text("learning")
      expect(parsed_html).to have_link("Back to dashboard", href: dashboard_path)
    end
  end

  describe "tags/_tag" do
    it "renders the tag fields" do
      tag = create(:tag, title: "fitness")

      render partial: "tags/tag", locals: { tag: tag }

      expect(parsed_html).to have_text("Title:")
      expect(parsed_html).to have_text("fitness")
      expect(parsed_html).to have_text(tag.habit_id.to_s)
    end
  end
end
