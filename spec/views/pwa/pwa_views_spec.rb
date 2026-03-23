require "rails_helper"

RSpec.describe "PWA views", type: :view do
  describe "pwa/manifest.json" do
    it "renders the app manifest metadata" do
      view.lookup_context.formats = [:json]

      render template: "pwa/manifest"

      expect(rendered).to include("\"name\": \"QuestonautHabitTrackerApp\"")
      expect(rendered).to include("\"start_url\": \"/\"")
      expect(rendered).to include("\"display\": \"standalone\"")
      expect(rendered).to include("\"theme_color\": \"red\"")
    end
  end

  describe "pwa/service-worker.js" do
    it "renders the service worker stub" do
      view.lookup_context.formats = [:js]

      render template: "pwa/service-worker"

      expect(rendered).to include("self.addEventListener(\"push\"")
      expect(rendered).to include("clients.openWindow")
    end
  end
end
