class Habit < ApplicationRecord
  CATEGORIES = %w[health productivity learning fitness nutrition].freeze
  FREQUENCIES = %w[daily weekly].freeze

  attr_accessor :category_name

  belongs_to :user

  has_many :habit_logs, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :title, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }

  after_save :sync_primary_category

  def completed_on?(date)
    habit_logs.where(date: date, completed: true).exists?
  end

  def current_streak(as_of: Date.current)
    target_date = if completed_on?(as_of)
      as_of
    elsif completed_on?(as_of - 1.day)
      as_of - 1.day
    end

    return 0 unless target_date

    streak_ending_on(target_date)
  end

  def streak_reset_alert?(as_of: Date.current)
    return false unless frequency == "daily"
    return false if completed_on?(as_of - 1.day)

    streak_ending_on(as_of - 2.days).positive?
  end

  def streak_before_reset(as_of: Date.current)
    return 0 unless streak_reset_alert?(as_of: as_of)

    streak_ending_on(as_of - 2.days)
  end

  def primary_category
    tags.first&.title&.downcase.presence_in(CATEGORIES) || "productivity"
  end

  private

  def streak_ending_on(date)
    return 0 unless date

    dates = habit_logs.where(completed: true).where("date <= ?", date).order(date: :desc).pluck(:date)
    return 0 unless dates.first == date

    streak = 1
    dates.each_cons(2) do |current_date, previous_date|
      break unless current_date == previous_date + 1.day

      streak += 1
    end
    streak
  end

  def sync_primary_category
    category = category_name.to_s.downcase
    return if category.blank?
    return unless CATEGORIES.include?(category)

    primary_tag = tags.first || tags.build
    primary_tag.update!(title: category)
  end
end
