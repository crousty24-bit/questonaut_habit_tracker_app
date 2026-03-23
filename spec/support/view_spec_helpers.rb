module ViewSpecHelpers
  def parsed_html
    Capybara.string(rendered)
  end

  def define_view_method(name, value = nil, &block)
    view.singleton_class.send(:define_method, name, &(block || proc { value }))
  end

  def stub_guest_user(current_path: nil, cookie_values: {})
    allow(view).to receive(:user_signed_in?).and_return(false)
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:current_page?) { |path| current_path.present? && path == current_path }
    allow(view).to receive(:cookies).and_return(cookie_values.with_indifferent_access)
  end

  def stub_signed_in_user(user, current_path: nil, cookie_values: {})
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_page?) { |path| current_path.present? && path == current_path }
    allow(view).to receive(:cookies).and_return(cookie_values.with_indifferent_access)
  end

  def stub_validation_helpers
    define_view_method(:validation_feedback_data) { |_record| {} }
    define_view_method(:validation_field_classes) { |_record, _attribute, base_class| base_class }
    define_view_method(:validation_field_data) { |_attribute| {} }
  end

  def stub_devise_view(resource:, controller_name:, minimum_password_length: 6)
    define_view_method(:resource, resource)
    define_view_method(:resource_name, :user)
    define_view_method(:resource_class, User)
    define_view_method(:devise_mapping, Devise.mappings[:user])
    define_view_method(:controller_name, controller_name)
    view.request.env["devise.mapping"] = Devise.mappings[:user]
    assign(:minimum_password_length, minimum_password_length)
    stub_validation_helpers
  end

  def assign_dashboard_state(user:, habits:, today: Date.current, now: Time.zone.parse("2026-03-23 12:00:00"))
    assign(:habits, habits)
    assign(:today, today)
    assign(:now, now)
    assign(:weekly_completed_logs, HabitLog.joins(:habit).where(habits: { user_id: user.id }).where(date: 6.days.ago..today, completed: true))
    assign(:current_category, nil)
    assign(:new_habit, user.habits.new(category_name: "health"))
    assign(:editing_habit, user.habits.new)
    assign(:deleting_habit, nil)
    assign(:recent_badges, [])
    assign(:streak_reset_habits, [])
  end
end
