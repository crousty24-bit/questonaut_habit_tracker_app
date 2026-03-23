module RequestSpecHelpers
  def login_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  def logout
    delete destroy_user_session_path
  end
end
