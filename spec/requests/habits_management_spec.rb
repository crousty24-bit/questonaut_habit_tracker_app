require "rails_helper"

RSpec.describe "Habit management" do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  def turbo_stream_headers
    { "HTTP_ACCEPT" => "text/vnd.turbo-stream.html" }
  end

  def dashboard_fragment_from(body)
    stream = Nokogiri::HTML5.fragment(body).at_css('turbo-stream[target="dashboard_content"] template')
    Nokogiri::HTML5.fragment(stream.inner_html)
  end

  def create_modal_form_from(body)
    dashboard_fragment_from(body).at_css("#createHabitModal form")
  end

  it "allows an authenticated user to create a new mission" do
    user = create_user(email: "creator@example.com")

    login_as(user)
    follow_redirect!

    expect do
      post habits_path, habit: {
        title: "Morning Stretch",
        description: "Ten minutes of mobility work",
        frequency: "daily",
        category_name: "fitness"
      }
    end.to change(Habit, :count).by(1)
      .and change(Tag, :count).by(1)

    created_habit = Habit.order(:created_at).last

    expect(last_response.status).to eq(302)
    expect(created_habit.title).to eq("Morning Stretch")
    expect(created_habit.primary_category).to eq("fitness")
    expect(user.reload.total_xp).to eq(20)
  end

  it "awards the First Mission badge when the user creates their first habit" do
    Badge.create!(name: "First Mission")
    user = create_user(email: "first-mission@example.com")

    login_as(user)
    follow_redirect!

    post habits_path, habit: {
      title: "Morning Stretch",
      description: "Ten minutes of mobility work",
      frequency: "daily",
      category_name: "fitness"
    }

    expect(last_response.status).to eq(302)
    expect(user.reload.badges.pluck(:name)).to include("First Mission")
  end

  it "allows an authenticated user to edit a mission" do
    user = create_user(email: "editor@example.com")
    habit = create_habit(user: user, title: "Read", description: "Read 10 pages", category_name: "learning")

    login_as(user)
    follow_redirect!

    patch habit_path(habit), habit: {
      title: "Read a chapter",
      description: "Read one full chapter",
      frequency: "weekly",
      category_name: "productivity"
    }

    expect(last_response.status).to eq(302)
    expect(habit.reload.title).to eq("Read a chapter")
    expect(habit.description).to eq("Read one full chapter")
    expect(habit.frequency).to eq("weekly")
    expect(habit.primary_category).to eq("productivity")
  end

  it "allows an authenticated user to delete a mission" do
    user = create_user(email: "destroyer@example.com")
    habit = create_habit(user: user, title: "Journal")

    login_as(user)
    follow_redirect!

    expect do
      delete habit_path(habit)
    end.to change(Habit, :count).by(-1)

    expect(last_response.status).to eq(302)
    expect(user.habits.reload).to be_empty
  end

  it "resets the create mission modal after a successful create" do
    user = create_user(email: "creator-modal@example.com")

    login_as(user)
    follow_redirect!

    post habits_path,
         { habit: {
           title: "Launch Prep",
           description: "Prepare the cockpit",
           frequency: "weekly",
           category_name: "fitness"
         } },
         turbo_stream_headers

    expect(last_response.status).to eq(200)

    create_form = create_modal_form_from(last_response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form["method"]).to eq("post")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end

  it "resets the create mission modal after a successful edit" do
    user = create_user(email: "editor-modal@example.com")
    habit = create_habit(user: user, title: "Read", description: "Read 10 pages", category_name: "learning")

    login_as(user)
    follow_redirect!

    patch habit_path(habit),
          { habit: {
            title: "Read a chapter",
            description: "Read one full chapter",
            frequency: "weekly",
            category_name: "productivity"
          } },
          turbo_stream_headers

    expect(last_response.status).to eq(200)

    create_form = create_modal_form_from(last_response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end

  it "resets the create mission modal after a successful delete" do
    user = create_user(email: "destroyer-modal@example.com")
    habit = create_habit(user: user, title: "Journal", description: "Log the day", category_name: "nutrition")

    login_as(user)
    follow_redirect!

    delete habit_path(habit), {}, turbo_stream_headers

    expect(last_response.status).to eq(200)

    create_form = create_modal_form_from(last_response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end
end
