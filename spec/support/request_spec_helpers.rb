module RequestSpecHelpers
  include Rack::Test::Methods
  include Rails.application.routes.url_helpers

  def app
    Rails.application
  end

  def login_as(user, password: "password123")
    post user_session_path, user: { email: user.email, password: password }
  end

  def logout
    delete destroy_user_session_path
  end
end
