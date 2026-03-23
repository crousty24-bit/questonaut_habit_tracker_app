require "rails_helper"

RSpec.describe "Devise views", type: :view do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe "devise/sessions/new" do
    it "renders the login form and navigation links" do
      stub_devise_view(resource: User.new, controller_name: "sessions")

      render template: "devise/sessions/new"

      expect(parsed_html).to have_text("Log In")
      expect(parsed_html).to have_button("Launch Mission")
      expect(parsed_html).to have_link("Forgot password?", href: new_user_password_path)
      expect(parsed_html).to have_link("Sign up", href: new_user_registration_path)
    end
  end

  describe "devise/registrations/new" do
    it "renders the signup form including terms acceptance" do
      stub_devise_view(resource: User.new, controller_name: "registrations")

      render template: "devise/registrations/new"

      expect(parsed_html).to have_text("Sign Up")
      expect(parsed_html).to have_field("user_name")
      expect(parsed_html).to have_field("user_email")
      expect(parsed_html).to have_field("user_password")
      expect(parsed_html).to have_field("user_password_confirmation")
      expect(parsed_html).to have_unchecked_field("user_terms_accepted")
      expect(parsed_html).to have_link("Terms of Use (CGU)", href: terms_path)
    end
  end

  describe "devise/passwords/new" do
    it "renders the password reset request form" do
      stub_devise_view(resource: User.new, controller_name: "passwords")

      render template: "devise/passwords/new"

      expect(parsed_html).to have_text("Forgot your password?")
      expect(parsed_html).to have_field("user_email")
      expect(parsed_html).to have_button("Send me password reset instructions")
    end
  end

  describe "devise/passwords/edit" do
    it "renders the password change form with reset token" do
      resource = User.new(reset_password_token: "token123")
      stub_devise_view(resource: resource, controller_name: "passwords", minimum_password_length: 6)

      render template: "devise/passwords/edit"

      expect(parsed_html).to have_text("Change your password")
      expect(rendered).to include("token123")
      expect(parsed_html).to have_field("user_password")
      expect(parsed_html).to have_field("user_password_confirmation")
      expect(parsed_html).to have_button("Change my password")
    end
  end

  describe "devise/registrations/edit" do
    it "renders the account update form and dashboard back link" do
      resource = User.new(email: "commander@example.com")
      resource.define_singleton_method(:pending_reconfirmation?) { false }
      resource.define_singleton_method(:unconfirmed_email) { nil }
      stub_devise_view(resource: resource, controller_name: "registrations", minimum_password_length: 6)

      render template: "devise/registrations/edit"

      expect(parsed_html).to have_text("Edit User")
      expect(parsed_html).to have_field("user_email", with: "commander@example.com")
      expect(parsed_html).to have_field("user_password")
      expect(parsed_html).to have_field("user_password_confirmation")
      expect(parsed_html).to have_field("user_current_password")
      expect(parsed_html).to have_button("Update")
      expect(parsed_html).to have_link("Back to dashboard", href: dashboard_path)
    end
  end

  describe "devise/shared/_links" do
    it "shows the session-side links" do
      stub_devise_view(resource: User.new, controller_name: "sessions")

      render partial: "devise/shared/links"

      expect(parsed_html).to have_link("Sign up", href: new_user_registration_path)
      expect(parsed_html).to have_link("Forgot your password?", href: new_user_password_path)
    end

    it "shows the registration-side login link" do
      stub_devise_view(resource: User.new, controller_name: "registrations")

      render partial: "devise/shared/links"

      expect(parsed_html).to have_link("Log in", href: new_user_session_path)
      expect(parsed_html).not_to have_link("Sign up", href: new_user_registration_path)
    end
  end

  describe "devise/shared/_error_messages" do
    it "lists resource errors" do
      resource = build(:user, email: "bad")
      resource.valid?
      stub_devise_view(resource: resource, controller_name: "registrations")

      render partial: "devise/shared/error_messages", locals: { resource: resource }

      expect(parsed_html).to have_text("Email is invalid")
    end
  end
end
