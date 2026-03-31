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
    habit_logs.where(validated_on: date.to_date).exists?
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

  def projected_streak(as_of: Date.current)
    return weekly_projected_streak(as_of: as_of) if frequency == "weekly"

    return streak_ending_on(as_of.to_date) if completed_on?(as_of)
    return streak_ending_on(as_of.to_date - 1.day) + 1 if completed_on?(as_of.to_date - 1.day)

    1
  end

  def success_rate
    total_periods = tracked_periods_count
    return 0 if total_periods.zero?

    ((completed_periods_count.to_f / total_periods) * 100).round
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

  def recalculate_streaks!
    logs = habit_logs.order(:validated_on, :id).to_a
    return if logs.empty?

    frequency == "weekly" ? recalculate_weekly_streaks!(logs) : recalculate_daily_streaks!(logs)
  end

  private

  def streak_ending_on(date)
    return 0 unless date

    dates = habit_logs.where("validated_on <= ?", date).order(validated_on: :desc).pluck(:validated_on)
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

  def weekly_projected_streak(as_of: Date.current)
    return weekly_streak_ending_on(as_of.to_date) if completed_during_week?(as_of)
    return weekly_streak_ending_on((as_of - 1.week).to_date) + 1 if completed_during_week?(as_of - 1.week)

    1
  end

  def completed_during_week?(date)
    week_range = date.to_date.beginning_of_week(:monday)..date.to_date.end_of_week(:monday)
    habit_logs.where(validated_on: week_range).exists?
  end

  def weekly_streak_ending_on(date)
    dates = habit_logs.where("validated_on <= ?", date).order(validated_on: :desc).pluck(:validated_on)
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

  def tracked_periods_count(as_of: Date.current)
    start_date = created_at&.to_date || as_of.to_date
    current_date = as_of.to_date
    return 0 if start_date > current_date

    if frequency == "weekly"
      start_week = start_date.beginning_of_week(:monday)
      end_week = current_date.beginning_of_week(:monday)

      (((end_week - start_week).to_i / 7) + 1).clamp(0, Float::INFINITY)
    else
      (current_date - start_date).to_i + 1
    end
  end

  def completed_periods_count(as_of: Date.current)
    if frequency == "weekly"
      habit_logs.where("validated_on <= ?", as_of.to_date)
               .pluck(:validated_on)
               .map { |date| date.beginning_of_week(:monday) }
               .uniq
               .count
    else
      habit_logs.where("validated_on <= ?", as_of.to_date).distinct.count(:validated_on)
    end
  end

  def recalculate_daily_streaks!(logs)
    streak = 0
    previous_date = nil

    logs.each do |log|
      streak = previous_date == log.validated_on - 1.day ? streak + 1 : 1
      log.update_columns(streak_days: streak)
      previous_date = log.validated_on
    end
  end

  def recalculate_weekly_streaks!(logs)
    streak = 0
    previous_week_start = nil

    logs.each do |log|
      current_week_start = log.validated_on.beginning_of_week(:monday)

      if previous_week_start == current_week_start
        log.update_columns(streak_days: streak)
        next
      end

      streak = previous_week_start == current_week_start - 1.week ? streak + 1 : 1
      log.update_columns(streak_days: streak)
      previous_week_start = current_week_start
    end
  end

  def sync_primary_category
    category = category_name.to_s.downcase
    return if category.blank?
    return unless CATEGORIES.include?(category)

    primary_tag = tags.first || tags.build
    primary_tag.update!(title: category)
  end
end
