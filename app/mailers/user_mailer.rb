class UserMailer < ApplicationMailer
  default from: -> { Rails.application.credentials.dig(:GMAIL_LOGIN).presence || "from@example.com" }

  def welcome_email(user)
    @user = user

    @url = new_user_session_url

    mail(to: @user.email, subject: "Welcome to Questonaut")
  end
end
