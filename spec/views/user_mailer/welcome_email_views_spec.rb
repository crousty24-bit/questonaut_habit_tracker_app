require "rails_helper"

RSpec.describe "User mailer views", type: :view do
  before do
    assign(:user, build_stubbed(:user, name: "Captain Nova", email: "captain.nova@example.com"))
    assign(:url, new_user_session_url)
  end

  describe "user_mailer/welcome_email.html" do
    it "renders the welcome email HTML content" do
      render template: "user_mailer/welcome_email"

      expect(parsed_html).to have_text("Hello Captain Nova,")
      expect(parsed_html).to have_text("Welcome to Questonaut !")
      expect(parsed_html).to have_text("captain.nova@example.com")
      expect(parsed_html).to have_text(new_user_session_url)
    end
  end

  describe "user_mailer/welcome_email.text" do
    it "renders the welcome email plain text content" do
      view.lookup_context.formats = [:text]
      render template: "user_mailer/welcome_email"

      expect(rendered).to include("Hello Captain Nova,")
      expect(rendered).to include("captain.nova@example.com")
      expect(rendered).to include(new_user_session_url)
    end
  end
end
