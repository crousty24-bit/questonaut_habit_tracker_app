class AddLevelXpToUsers < ActiveRecord::Migration[8.0]
  MAX_LEVEL = 300
  LEVEL_ONE_OFFSET = 15 * 1 * 1 + 100 * 1 + 200

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    rename_column :users, :total_xp, :xp_total
    add_column :users, :xp, :integer, default: 0, null: false

    change_column_default :users, :level, from: nil, to: 1
    change_column_null :users, :level, false, 1
    change_column_default :users, :xp_total, from: nil, to: 0
    change_column_null :users, :xp_total, false, 0

    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      xp_total = [user.xp_total.to_i, 0].max
      level = level_from_total_xp(xp_total)
      xp = xp_within_level(xp_total)
      xp = 0 if level >= MAX_LEVEL

      user.update_columns(level: level, xp_total: xp_total, xp: xp)
    end
  end

  def down
    remove_column :users, :xp, :integer
    rename_column :users, :xp_total, :total_xp
    change_column_null :users, :level, true
    change_column_default :users, :level, from: 1, to: nil
    change_column_null :users, :total_xp, true
    change_column_default :users, :total_xp, from: 0, to: nil
  end

  private

  def level_from_total_xp(total_xp)
    xp_total = [total_xp.to_i, 0].max
    low = 1
    high = MAX_LEVEL

    while low < high
      mid = (low + high + 1) / 2

      if xp_threshold_for_level(mid) <= xp_total
        low = mid
      else
        high = mid - 1
      end
    end

    low
  end

  def xp_within_level(total_xp)
    xp_total = [total_xp.to_i, 0].max
    level = level_from_total_xp(xp_total)
    return 0 if level >= MAX_LEVEL

    xp_total - xp_threshold_for_level(level)
  end

  def xp_threshold_for_level(level)
    level_value = normalized_level(level)
    return 0 if level_value <= 1

    raw_total_xp_for_level(level_value) - LEVEL_ONE_OFFSET
  end

  def raw_total_xp_for_level(level)
    level_value = normalized_level(level)

    15 * level_value * level_value + 100 * level_value + 200
  end

  def normalized_level(level)
    [[level.to_i, 1].max, MAX_LEVEL].min
  end
end
