require "rails_helper"

RSpec.describe "JSON views", type: :view do
  def parsed_json
    JSON.parse(rendered)
  end

  before do
    allow_any_instance_of(User).to receive(:welcome_send)
    view.lookup_context.formats = [:json]
  end

  describe "badges JSON" do
    it "renders a badge partial payload" do
      badge = create(:badge, name: "Explorer", description: "Reach a new milestone")

      render partial: "badges/badge", formats: :json, locals: { badge: badge }

      expect(parsed_json["name"]).to eq("Explorer")
      expect(parsed_json["description"]).to eq("Reach a new milestone")
      expect(parsed_json["url"]).to eq(badge_url(badge, format: :json))
    end

    it "renders the badge collection payload" do
      badge = create(:badge, name: "Navigator")
      assign(:badges, [badge])

      render template: "badges/index"

      expect(parsed_json.first["name"]).to eq("Navigator")
    end

    it "renders the badge detail payload" do
      badge = create(:badge, name: "Navigator")
      assign(:badge, badge)

      render template: "badges/show"

      expect(parsed_json["id"]).to eq(badge.id)
    end
  end

  describe "habit_logs JSON" do
    it "renders a nested habit log partial payload" do
      habit_log = create(:habit_log)

      render partial: "habit_logs/habit_log", formats: :json, locals: { habit_log: habit_log }

      expect(parsed_json["habit_id"]).to eq(habit_log.habit_id)
      expect(parsed_json["url"]).to eq(habit_habit_log_url(habit_log.habit, habit_log, format: :json))
    end

    it "renders the habit log collection payload" do
      habit_log = create(:habit_log)
      assign(:habit_logs, [habit_log])

      render template: "habit_logs/index"

      expect(parsed_json.first["id"]).to eq(habit_log.id)
    end

    it "renders the habit log detail payload" do
      habit_log = create(:habit_log)
      assign(:habit_log, habit_log)

      render template: "habit_logs/show"

      expect(parsed_json["validated_on"]).to eq(habit_log.validated_on.to_s)
      expect(parsed_json["streak_days"]).to eq(habit_log.streak_days)
    end
  end

  describe "tags JSON" do
    it "renders a tag partial payload without an invalid member url" do
      tag = create(:tag, title: "learning")

      render partial: "tags/tag", formats: :json, locals: { tag: tag }

      expect(parsed_json["title"]).to eq("learning")
      expect(parsed_json).not_to have_key("url")
    end

    it "renders the tag collection payload" do
      tag = create(:tag, title: "fitness")
      assign(:tags, [tag])

      render template: "tags/index"

      expect(parsed_json.first["title"]).to eq("fitness")
      expect(parsed_json.first["habit_id"]).to eq(tag.habit_id)
    end
  end
end
