require "rails_helper"

RSpec.describe "Shared views", type: :view do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
    stub_validation_helpers
  end

  describe "layouts/application" do
    it "renders the global layout shell" do
      stub_guest_user

      render inline: "<p>Mission body</p>", layout: "layouts/application"

      expect(rendered).to include("<main>")
      expect(parsed_html).to have_text("Mission body")
      expect(parsed_html).to have_text("Questonaut")
      expect(parsed_html).to have_text("Cookies")
    end
  end

  describe "shared/_navbar" do
    it "shows guest navigation" do
      stub_guest_user

      render partial: "shared/navbar"

      expect(parsed_html).to have_link("Questonaut", href: root_path)
      expect(parsed_html).to have_link("Start Mission", href: new_user_session_path)
      expect(parsed_html).not_to have_text("Statistics")
    end

    it "shows signed-in navigation and commander meta" do
      user = create(:user, name: "Captain Nova", level: 3)
      stub_signed_in_user(user, current_path: dashboard_path)

      render partial: "shared/navbar"

      expect(parsed_html).to have_link("Dashboard", href: dashboard_path)
      expect(parsed_html).to have_link("Statistics", href: statistics_path)
      expect(parsed_html).to have_text("Captain Nova")
      expect(parsed_html).to have_button("Logout")
    end
  end

  describe "shared/_footer" do
    it "shows the footer legal links" do
      render partial: "shared/footer"

      expect(parsed_html).to have_text("Questonaut")
      expect(parsed_html).to have_link("Terms of Use", href: terms_path)
      expect(parsed_html).to have_link("Cookie Policy", href: cookies_path)
    end
  end

  describe "shared/_cookie_banner" do
    it "renders the banner when consent is missing" do
      stub_guest_user(cookie_values: {})

      render partial: "shared/cookie_banner"

      expect(parsed_html).to have_text("Questonaut uses essential cookies")
      expect(parsed_html).to have_button("Essential only")
      expect(parsed_html).to have_button("Accept all")
      expect(parsed_html).to have_link("Learn more", href: cookies_path)
    end

    it "does not render the banner when consent already exists" do
      stub_guest_user(cookie_values: { cookie_consent: "all" })

      render partial: "shared/cookie_banner"

      expect(rendered.strip).to eq("")
    end
  end

  describe "shared/_model_errors" do
    it "renders unique field errors for the record" do
      habit = build(:habit, title: "")
      habit.valid?

      render partial: "shared/model_errors", locals: { record: habit }

      expect(parsed_html).to have_text("Title can't be blank")
      expect(parsed_html).to have_text("Title is too short")
    end
  end

  describe "shared/_validation_toast" do
    it "renders no visible markup" do
      render partial: "shared/validation_toast", locals: { message: "Forbidden content" }

      expect(rendered.strip).to eq("")
    end
  end
end
