module SystemAuthHelpers
  def visit_sign_in_from_home
    visit root_path
    click_link "Launch Mission"
  end

  def visit_sign_up_from_sign_in
    visit new_user_session_path
    click_link "Sign up"
  end

  def submit_sign_in_form(email:, password: TestDataHelpers::DEFAULT_PASSWORD)
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    click_button "Launch Mission"
  end

  def submit_sign_up_form(name:, email:, password: TestDataHelpers::DEFAULT_PASSWORD, password_confirmation: password)
    fill_in "user_name", with: name
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password_confirmation
    click_button "Start Mission"
  end

  def sign_in_via_ui(user, password: TestDataHelpers::DEFAULT_PASSWORD)
    visit new_user_session_path
    submit_sign_in_form(email: user.email, password: password)
  end

  def sign_up_via_ui(name:, email:, password: TestDataHelpers::DEFAULT_PASSWORD)
    visit new_user_registration_path
    submit_sign_up_form(name: name, email: email, password: password)
  end
end
