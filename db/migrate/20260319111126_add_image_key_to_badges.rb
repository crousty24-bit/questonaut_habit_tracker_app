class AddImageKeyToBadges < ActiveRecord::Migration[8.0]
  def change
    add_column :badges, :image_key, :string
  end
end
