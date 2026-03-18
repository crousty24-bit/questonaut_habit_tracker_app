class Habit < ApplicationRecord
  CATEGORIES = %w[health productivity learning fitness].freeze
  FREQUENCIES = %w[daily weekly].freeze

  attr_accessor :category_name

  belongs_to :user

  has_many :habit_logs, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :title, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }

  after_save :sync_primary_category

  def primary_category
    tags.first&.title&.downcase.presence_in(CATEGORIES) || "productivity"
  end

  private

  def sync_primary_category
    category = category_name.to_s.downcase
    return if category.blank?
    return unless CATEGORIES.include?(category)

    primary_tag = tags.first || tags.build
    primary_tag.update!(title: category)
  end
end
