module SystemAuthHelpers
  def sign_in_via_ui(user, password: TestDataHelpers::DEFAULT_PASSWORD)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: password
    click_button "Launch Mission"
  end

  def sign_up_via_ui(name:, email:, password: TestDataHelpers::DEFAULT_PASSWORD)
    visit new_user_registration_path
    fill_in "user_name", with: name
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    fill_in "user_password_confirmation", with: password
    check "user_terms_accepted"
    click_button "Start Mission"
  end
end
