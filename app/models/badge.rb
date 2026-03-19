class Badge < ApplicationRecord
  has_many :user_badges
  has_many :users, through: :user_badges
  validates :name, presence: true

  def image_path
    "/badges/#{image_key}"
  end

  def locked_image_path
    "/badges/locked/#{image_key}"
  end
end
