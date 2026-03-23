require "rails_helper"

RSpec.describe "Authentication" do
  it "requires accepting the terms to sign up" do
    visit new_user_registration_path

    expect do
      submit_sign_up_form(
        name: "Captain Nova",
        email: "captain.nova.terms@example.com",
        password: TestDataHelpers::DEFAULT_PASSWORD,
        password_confirmation: TestDataHelpers::DEFAULT_PASSWORD,
        accept_terms: false
      )
    end.not_to change(User, :count)

    expect(page).to have_css("#error_explanation")
    expect(page).to have_text("Terms accepted must be accepted")
  end

  it "completes the signup process and sends a welcome email" do
    visit_sign_up_from_sign_in

    expect(page).to have_current_path(new_user_registration_path, ignore_query: true)

    expect do
      submit_sign_up_form(name: "Captain Nova", email: "captain.nova@example.com")
    end.to change(User, :count).by(1)
      .and change { ActionMailer::Base.deliveries.count }.by(1)

    expect(page).to have_current_path(dashboard_path, ignore_query: true)
    expect(page).to have_button("Logout")
    expect(page).to have_text("Captain Nova")
    expect(page).to have_link("Dashboard")

    sent_email = ActionMailer::Base.deliveries.last

    expect(sent_email.to).to include("captain.nova@example.com")
    expect(sent_email.subject).to eq("Welcome to Questonaut")
  end

  it "keeps the visitor on signup when the submitted data is invalid" do
    visit_sign_up_from_sign_in

    expect do
      submit_sign_up_form(
        name: "No",
        email: "not-an-email",
        password: "short",
        password_confirmation: "different"
      )
    end.not_to change(User, :count)

    expect(page).to have_css("#error_explanation")
    expect(page).to have_text("Name is too short (minimum is 3 characters)")
    expect(page).to have_text("Email is invalid")
    expect(page).to have_text("Password is too short (minimum is 6 characters)")
    expect(page).to have_text("Password confirmation doesn't match Password")
    expect(page).to have_no_button("Logout")
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "completes the login process for an existing user" do
    user = create(:user, name: "Pilot Vega", email: "pilot.vega@example.com")

    visit_sign_in_from_home

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)

    submit_sign_in_form(email: user.email)

    expect(page).to have_current_path(dashboard_path, ignore_query: true)
    expect(page).to have_button("Logout")
    expect(page).to have_text("Pilot Vega")
    expect(page).to have_link("Statistics")
  end

  it "rejects login with invalid credentials" do
    user = create(:user, name: "Pilot Vega", email: "pilot.vega@example.com")

    visit_sign_in_from_home
    submit_sign_in_form(email: user.email, password: "wrong-password")

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_css(".auth-header__title", text: "Log In")
    expect(page).to have_no_button("Logout")
    expect(page).to have_link("Sign up")
  end

  it "allows an authenticated user to log out" do
    user = create(:user, name: "Commander Orion", email: "orion@example.com")

    sign_in_via_ui(user)
    click_button "Logout"

    expect(page).to have_link("Start Mission")
    expect(page).to have_no_button("Logout")
  end
end
