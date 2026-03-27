class Habit < ApplicationRecord
  CATEGORIES = %w[health productivity learning fitness nutrition].freeze
  FREQUENCIES = %w[daily weekly].freeze

  attr_accessor :category_name

  belongs_to :user

  has_many :habit_logs, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :title,
    presence: true,
    length: { minimum: 3, maximum: 50 },
    content: true

  validates :description,
    length: { maximum: 200 },
    content: true,
    allow_blank: true

  validates :frequency, inclusion: { in: FREQUENCIES }

  after_save :sync_primary_category

  def completed_on?(date)
    habit_logs.where(date: date, completed: true).exists?
  end

  def current_streak(as_of: Date.current)
    return weekly_streak(as_of: as_of) if frequency == "weekly"

    target_date = if completed_on?(as_of)
      as_of
    elsif completed_on?(as_of - 1.day)
      as_of - 1.day
    end

    return 0 unless target_date

    streak_ending_on(target_date)
  end

  def success_rate
    total_logs = habit_logs.count
    return 0 if total_logs.zero?

    ((habit_logs.count(&:completed?) / total_logs.to_f) * 100).round
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

  def weekly_streak(as_of: Date.current)
    period_end = if completed_during_week?(as_of)
      as_of.to_date
    elsif completed_during_week?(as_of - 1.week)
      (as_of - 1.week).to_date
    end

    return 0 unless period_end

    weekly_streak_ending_on(period_end)
  end

  def completed_during_week?(date)
    week_range = date.to_date.beginning_of_week(:monday)..date.to_date.end_of_week(:monday)
    habit_logs.where(completed: true, date: week_range).exists?
  end

  def weekly_streak_ending_on(date)
    dates = habit_logs.where(completed: true).where("date <= ?", date).order(date: :desc).pluck(:date)
    week_starts = dates.map { |logged_date| logged_date.beginning_of_week(:monday) }.uniq
    target_week = date.beginning_of_week(:monday)
    return 0 unless week_starts.first == target_week

    streak = 1
    week_starts.each_cons(2) do |current_week, previous_week|
      break unless current_week == previous_week + 1.week

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
