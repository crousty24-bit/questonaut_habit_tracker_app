module TestDataHelpers
  DEFAULT_PASSWORD = "password123".freeze

  def user_attributes(**attributes)
    {
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    }.merge(attributes)
  end

  def create_user(**attributes)
    FactoryBot.create(:user, **user_attributes(**attributes))
  end

  def build_user(**attributes)
    FactoryBot.build(:user, **user_attributes(**attributes))
  end

  def create_habit(user: nil, **attributes)
    FactoryBot.create(:habit, user: user || create_user, **attributes)
  end

  def build_habit(user: nil, **attributes)
    FactoryBot.build(:habit, user: user || build_user, **attributes)
  end
end
