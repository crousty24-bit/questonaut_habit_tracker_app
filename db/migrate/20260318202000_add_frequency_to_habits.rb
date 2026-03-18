class AddFrequencyToHabits < ActiveRecord::Migration[8.0]
  def change
    add_column :habits, :frequency, :string, null: false, default: "daily"
  end
end
