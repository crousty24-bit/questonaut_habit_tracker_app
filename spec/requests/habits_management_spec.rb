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

  def html_text_for(body)
    Nokogiri::HTML5.parse(body).text
  end

  it "allows an authenticated user to create a new mission" do
    user = create(:user, email: "creator@example.com")
    habit_attributes = attributes_for(
      :habit,
      title: "Morning Stretch",
      description: "Ten minutes of mobility work",
      frequency: "daily",
      category_name: "fitness"
    )

    login_as(user)
    follow_redirect!

    expect do
      post habits_path, params: { habit: habit_attributes }
    end.to change(Habit, :count).by(1)
      .and change(Tag, :count).by(1)

    created_habit = Habit.order(:created_at).last

    expect(response).to have_http_status(:found)
    expect(created_habit.title).to eq("Morning Stretch")
    expect(created_habit.primary_category).to eq("fitness")
    expect(user.reload.xp_total).to eq(0)
  end

  it "awards the First Mission badge when the user creates their first habit" do
    create(:badge, name: "First Mission")
    user = create(:user, email: "first-mission@example.com")

    login_as(user)
    follow_redirect!

    post habits_path, params: {
      habit: attributes_for(
        :habit,
        title: "Morning Stretch",
        description: "Ten minutes of mobility work",
        frequency: "daily",
        category_name: "fitness"
      )
    }

    expect(response).to have_http_status(:found)
    expect(user.reload.badges.pluck(:name)).to include("First Mission")
  end

  it "allows an authenticated user to edit a mission" do
    user = create(:user, email: "editor@example.com")
    habit = create(:habit, user: user, title: "Read", description: "Read 10 pages", category_name: "learning")

    login_as(user)
    follow_redirect!

    patch habit_path(habit), params: {
      habit: {
        title: "Read a chapter",
        description: "Read one full chapter",
        frequency: "weekly",
        category_name: "productivity"
      }
    }

    expect(response).to have_http_status(:found)
    expect(habit.reload.title).to eq("Read a chapter")
    expect(habit.description).to eq("Read one full chapter")
    expect(habit.frequency).to eq("weekly")
    expect(habit.primary_category).to eq("productivity")
  end

  it "allows an authenticated user to delete a mission" do
    user = create(:user, email: "destroyer@example.com")
    habit = create(:habit, user: user, title: "Journal")

    login_as(user)
    follow_redirect!

    expect do
      delete habit_path(habit)
    end.to change(Habit, :count).by(-1)

    expect(response).to have_http_status(:found)
    expect(user.habits.reload).to be_empty
  end

  it "re-renders the dashboard with create modal errors when mission creation fails" do
    user = create(:user, email: "invalid-create@example.com")

    login_as(user)
    follow_redirect!

    expect do
      post habits_path, params: {
        habit: attributes_for(
          :habit,
          title: "",
          description: "Still trying to create a mission",
          frequency: "daily",
          category_name: "fitness"
        )
      }
    end.not_to change(Habit, :count)

    expect(response).to have_http_status(:unprocessable_content)
    expect(html_text_for(response.body)).to include("Title can't be blank")
    expect(response.body).to include('id="createHabitModal"')
    expect(response.body).to include("dashboard-mission-modal active")
  end

  it "re-renders the dashboard with edit modal errors when mission update fails" do
    user = create(:user, email: "invalid-update@example.com")
    habit = create(:habit, user: user, title: "Focus Session")

    login_as(user)
    follow_redirect!

    patch habit_path(habit), params: {
      habit: {
        title: "",
        description: "Updated description",
        frequency: "weekly",
        category_name: "learning"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(habit.reload.title).to eq("Focus Session")
    expect(html_text_for(response.body)).to include("Title can't be blank")
    expect(response.body).to include('id="editHabitModal"')
    expect(response.body).to include("dashboard-mission-modal active")
  end

  it "resets the create mission modal after a successful create" do
    user = create(:user, email: "creator-modal@example.com")

    login_as(user)
    follow_redirect!

    post habits_path,
         params: {
           habit: {
             title: "Launch Prep",
             description: "Prepare the cockpit",
             frequency: "weekly",
             category_name: "fitness"
           }
         },
         headers: turbo_stream_headers

    expect(response).to have_http_status(:ok)

    create_form = create_modal_form_from(response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form["method"]).to eq("post")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end

  it "resets the create mission modal after a successful edit" do
    user = create(:user, email: "editor-modal@example.com")
    habit = create(:habit, user: user, title: "Read", description: "Read 10 pages", category_name: "learning")

    login_as(user)
    follow_redirect!

    patch habit_path(habit),
          params: {
            habit: {
              title: "Read a chapter",
              description: "Read one full chapter",
              frequency: "weekly",
              category_name: "productivity"
            }
          },
          headers: turbo_stream_headers

    expect(response).to have_http_status(:ok)

    create_form = create_modal_form_from(response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end

  it "resets the create mission modal after a successful delete" do
    user = create(:user, email: "destroyer-modal@example.com")
    habit = create(:habit, user: user, title: "Journal", description: "Log the day", category_name: "nutrition")

    login_as(user)
    follow_redirect!

    delete habit_path(habit), headers: turbo_stream_headers

    expect(response).to have_http_status(:ok)

    create_form = create_modal_form_from(response.body)

    expect(create_form["action"]).to eq("/habits")
    expect(create_form.at_css('input[name="_method"][value="patch"]')).to be_nil
    expect(create_form.at_css('input[name="habit[title]"]')["value"].to_s).to eq("")
    expect(create_form.at_css('textarea[name="habit[description]"]').text).to eq("")
    expect(create_form.at_css('input[name="habit[frequency]"]')["value"]).to eq("daily")
    expect(create_form.at_css('input[name="habit[category_name]"]')["value"]).to eq("health")
  end
end
