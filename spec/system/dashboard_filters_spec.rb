require "rails_helper"

RSpec.describe "Dashboard category filters" do
  it "lets an authenticated user filter missions by category" do
    user = create_user(email: "filter-ui@example.com")
    create_habit(user: user, title: "Gym session", category_name: "fitness")
    create_habit(user: user, title: "Read a lesson", category_name: "learning")

    sign_in_via_ui(user)
    visit dashboard_path

    expect(page).to have_text("Gym session")
    expect(page).to have_text("Read a lesson")

    click_link "Fitness"

    expect(page).to have_text("Gym session")
    expect(page).to have_no_text("Read a lesson")
  end
end
