class AddDailyLoginTrackingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :last_daily_login, :date
    add_column :users, :login_streak, :integer
  end
end
