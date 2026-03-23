require "rails_helper"

RSpec.describe "Authentication" do
  it "requires accepting the terms to sign up" do
    expect do
      visit new_user_registration_path
      fill_in "user_name", with: "Captain Nova"
      fill_in "user_email", with: "captain.nova.terms@example.com"
      fill_in "user_password", with: "password123"
      fill_in "user_password_confirmation", with: "password123"
      click_button "Start Mission"

      expect(page).to have_css("#error_explanation")
      expect(page).to have_text("must be accepted")
    end.not_to change(User, :count)
  end

  it "allows a visitor to sign up" do
    expect do
      sign_up_via_ui(name: "Captain Nova", email: "captain.nova@example.com")
    end.to change(User, :count).by(1)

    expect(page).to have_button("Logout")
    expect(page).to have_text("Captain Nova")
    expect(page).to have_link("Dashboard")
  end

  it "allows a visitor to log in" do
    user = create_user(name: "Pilot Vega", email: "pilot.vega@example.com")

    sign_in_via_ui(user)

    expect(page).to have_button("Logout")
    expect(page).to have_text("Pilot Vega")
    expect(page).to have_link("Statistics")
  end

  it "allows an authenticated user to log out" do
    user = create_user(name: "Commander Orion", email: "orion@example.com")

    sign_in_via_ui(user)
    click_button "Logout"

    expect(page).to have_link("Start Mission")
    expect(page).to have_no_button("Logout")
  end
end
