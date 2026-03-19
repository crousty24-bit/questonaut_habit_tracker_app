require "rails_helper"

RSpec.describe "Authentication" do
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
