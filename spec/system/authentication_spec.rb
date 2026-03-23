require "rails_helper"

RSpec.describe "Authentication" do
  it "completes the signup process and sends a welcome email" do
    visit new_user_session_path

    click_link "Sign up"

    expect(page).to have_current_path(new_user_registration_path, ignore_query: true)

    expect do
      fill_in "user_name", with: "Captain Nova"
      fill_in "user_email", with: "captain.nova@example.com"
      fill_in "user_password", with: TestDataHelpers::DEFAULT_PASSWORD
      fill_in "user_password_confirmation", with: TestDataHelpers::DEFAULT_PASSWORD
      click_button "Start Mission"
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
    visit new_user_session_path

    click_link "Sign up"

    expect do
      fill_in "user_name", with: "No"
      fill_in "user_email", with: "not-an-email"
      fill_in "user_password", with: "short"
      fill_in "user_password_confirmation", with: "different"
      click_button "Start Mission"
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
    user = create_user(name: "Pilot Vega", email: "pilot.vega@example.com")

    visit root_path

    click_link "Launch Mission"

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)

    fill_in "user_email", with: user.email
    fill_in "user_password", with: TestDataHelpers::DEFAULT_PASSWORD
    click_button "Launch Mission"

    expect(page).to have_current_path(dashboard_path, ignore_query: true)
    expect(page).to have_button("Logout")
    expect(page).to have_text("Pilot Vega")
    expect(page).to have_link("Statistics")
  end

  it "rejects login with invalid credentials" do
    user = create_user(name: "Pilot Vega", email: "pilot.vega@example.com")

    visit root_path

    click_link "Launch Mission"

    fill_in "user_email", with: user.email
    fill_in "user_password", with: "wrong-password"
    click_button "Launch Mission"

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_css(".auth-header__title", text: "Log In")
    expect(page).to have_no_button("Logout")
    expect(page).to have_link("Sign up")
  end

  it "allows an authenticated user to log out" do
    user = create_user(name: "Commander Orion", email: "orion@example.com")

    sign_in_via_ui(user)
    click_button "Logout"

    expect(page).to have_link("Start Mission")
    expect(page).to have_no_button("Logout")
  end
end
