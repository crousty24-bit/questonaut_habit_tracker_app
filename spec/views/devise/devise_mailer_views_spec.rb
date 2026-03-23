require "rails_helper"

RSpec.describe "Devise mailer views", type: :view do
  describe "devise/mailer/reset_password_instructions" do
    it "renders the password reset message and link" do
      resource = build_stubbed(:user, email: "captain.nova@example.com")
      assign(:resource, resource)
      assign(:token, "reset-token-123")

      render template: "devise/mailer/reset_password_instructions"

      expect(parsed_html).to have_text("Hello captain.nova@example.com!")
      expect(parsed_html).to have_text("Someone has requested a link to change your password.")
      expect(parsed_html).to have_link(
        "Change my password",
        href: edit_user_password_url(reset_password_token: "reset-token-123")
      )
    end
  end

  describe "devise/mailer/email_changed" do
    it "renders the changed email notification" do
      resource = build_stubbed(:user, email: "captain.nova@example.com")
      resource.define_singleton_method(:unconfirmed_email?) { false }

      assign(:resource, resource)
      assign(:email, "captain.nova@example.com")

      render template: "devise/mailer/email_changed"

      expect(parsed_html).to have_text("Hello captain.nova@example.com!")
      expect(parsed_html).to have_text("your email has been changed to captain.nova@example.com")
    end
  end

  describe "devise/mailer/password_change" do
    it "renders the password change notification" do
      resource = build_stubbed(:user, email: "captain.nova@example.com")
      assign(:resource, resource)

      render template: "devise/mailer/password_change"

      expect(parsed_html).to have_text("Hello captain.nova@example.com!")
      expect(parsed_html).to have_text("your password has been changed")
    end
  end
end
