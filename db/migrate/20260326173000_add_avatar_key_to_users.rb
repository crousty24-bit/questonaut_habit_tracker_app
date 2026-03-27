class AddAvatarKeyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :avatar_key, :string, null: false, default: "avatar_marine"
  end
end
