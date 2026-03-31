class UpdateHabitLogsForGamifiedXp < ActiveRecord::Migration[8.0]
  class MigrationHabit < ActiveRecord::Base
    self.table_name = "habits"

    has_many :habit_logs, class_name: "UpdateHabitLogsForGamifiedXp::MigrationHabitLog", foreign_key: :habit_id
  end

  class MigrationHabitLog < ActiveRecord::Base
    self.table_name = "habit_logs"

    belongs_to :habit, class_name: "UpdateHabitLogsForGamifiedXp::MigrationHabit"
  end

  def up
    rename_column :habit_logs, :date, :validated_on
    add_column :habit_logs, :streak_days, :integer, default: 0, null: false

    MigrationHabitLog.reset_column_information
    MigrationHabit.reset_column_information

    MigrationHabitLog.where.not(completed: true).delete_all
    deduplicate_logs!
    backfill_streaks!

    remove_column :habit_logs, :completed, :boolean
    change_column_null :habit_logs, :validated_on, false
    remove_index :habit_logs, :habit_id
    add_index :habit_logs, [:habit_id, :validated_on], unique: true
  end

  def down
    remove_index :habit_logs, [:habit_id, :validated_on]
    add_index :habit_logs, :habit_id
    add_column :habit_logs, :completed, :boolean, default: true, null: false
    rename_column :habit_logs, :validated_on, :date
    remove_column :habit_logs, :streak_days, :integer
  end

  private

  def deduplicate_logs!
    duplicates = MigrationHabitLog.group(:habit_id, :validated_on).having("COUNT(*) > 1").pluck(:habit_id, :validated_on)

    duplicates.each do |habit_id, validated_on|
      MigrationHabitLog.where(habit_id: habit_id, validated_on: validated_on).order(:id).offset(1).delete_all
    end
  end

  def backfill_streaks!
    MigrationHabit.find_each do |habit|
      logs = habit.habit_logs.order(:validated_on, :id).to_a
      next if logs.empty?

      habit.frequency == "weekly" ? backfill_weekly_streaks(logs) : backfill_daily_streaks(logs)
    end
  end

  def backfill_daily_streaks(logs)
    streak = 0
    previous_date = nil

    logs.each do |log|
      streak = previous_date == log.validated_on - 1.day ? streak + 1 : 1
      log.update_columns(streak_days: streak)
      previous_date = log.validated_on
    end
  end

  def backfill_weekly_streaks(logs)
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
end
