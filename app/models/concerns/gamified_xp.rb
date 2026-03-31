module GamifiedXp
  MAX_LEVEL = 300

  # Option C: mixed rebalance.
  # We make the opening levels cheaper, but keep an eventual per-level slope that
  # stays close to the previous system once the player reaches the mid/late game.
  XP_NEEDED_BASE = 18.0
  XP_NEEDED_LINEAR_FACTOR = 15.0
  XP_NEEDED_CATCHUP_BONUS = 90.0
  XP_NEEDED_TRANSITION_LEVEL = 10.0
  XP_NEEDED_TRANSITION_SMOOTHING = 5.5

  # Early levels also receive a modest floor bonus on base XP so that level 1
  # validations feel rewarding immediately, while later levels remain scalable.
  XP_BASE_FLOOR = 19.0
  XP_BASE_LOG_FACTOR = 5.0
  XP_BASE_LEVEL_FACTOR = 0.12

  LEGACY_XP_NEEDED_LINEAR_FACTOR = 30.0
  LEGACY_XP_NEEDED_BASE = 115.0

  module_function

  # Total XP stored for the start of a level. Level 1 intentionally starts at 0.
  def xp_total_for_level(level)
    xp_thresholds[normalized_level(level)]
  end

  def xp_threshold_for_level(level)
    xp_total_for_level(level)
  end

  # Smooth early-game curve:
  # - levels 1-10 are noticeably cheaper
  # - the softplus term gradually restores a near-legacy slope afterwards
  def xp_needed_for_level(level)
    level_value = normalized_level(level)
    return 0 if level_value >= MAX_LEVEL

    (
      XP_NEEDED_BASE +
      (XP_NEEDED_LINEAR_FACTOR * level_value) +
      (XP_NEEDED_CATCHUP_BONUS * Math.log(1 + Math.exp((level_value - XP_NEEDED_TRANSITION_LEVEL) / XP_NEEDED_TRANSITION_SMOOTHING)))
    ).round
  end

  # Higher floor at low levels, then a gentle log + linear growth to stay readable
  # and rewarding without trivialising the late-game.
  def base_xp_for(level)
    level_value = normalized_level(level)

    XP_BASE_FLOOR +
      (XP_BASE_LOG_FACTOR * Math.log(level_value + 1)) +
      (XP_BASE_LEVEL_FACTOR * level_value)
  end

  # The streak multiplier stays intentionally familiar so the system keeps the
  # same habit-reinforcement feel as before.
  def streak_multiplier(streak)
    1 + 0.1 * Math.sqrt([streak.to_i, 0].max)
  end

  def xp_gain_for(level:, streak:)
    (base_xp_for(level) * streak_multiplier(streak)).round
  end

  def level_from_total_xp(total_xp)
    xp_total_value = [total_xp.to_i, 0].max
    low = 1
    high = MAX_LEVEL

    while low < high
      mid = (low + high + 1) / 2

      if xp_total_for_level(mid) <= xp_total_value
        low = mid
      else
        high = mid - 1
      end
    end

    low
  end

  def xp_within_level(total_xp)
    xp_total_value = [total_xp.to_i, 0].max
    level_value = level_from_total_xp(xp_total_value)
    return 0 if level_value >= MAX_LEVEL

    xp_total_value - xp_total_for_level(level_value)
  end

  def debug_xp_progression(io: $stdout)
    checkpoints = (1..10).to_a + [20, 50, 100, 200, 300]
    lines = []
    lines << "Level | XP needed old->new | Gain s1 old->new | Gain s7 new | Runs to next (s1) | Total XP new"

    checkpoints.each do |level|
      new_needed = xp_needed_for_level(level)
      old_needed = legacy_xp_needed_for_level(level)
      new_gain = xp_gain_for(level: level, streak: 1)
      old_gain = (legacy_base_xp_for(level) * streak_multiplier(1)).round
      streak_seven_gain = xp_gain_for(level: level, streak: 7)
      runs_to_next = new_needed.zero? ? 0 : (new_needed.to_f / [new_gain, 1].max).ceil

      lines << format(
        "%5d | %5d -> %-5d | %5d -> %-5d | %-11d | %-16d | %-12d",
        level,
        old_needed,
        new_needed,
        old_gain,
        new_gain,
        streak_seven_gain,
        runs_to_next,
        xp_total_for_level(level)
      )
    end

    output = lines.join("\n")
    io.puts(output)
    output
  end

  def normalized_level(level)
    [[level.to_i, 1].max, MAX_LEVEL].min
  end

  def xp_thresholds
    @xp_thresholds ||= begin
      thresholds = Array.new(MAX_LEVEL + 1, 0)
      running_total = 0
      thresholds[1] = 0

      2.upto(MAX_LEVEL) do |level|
        running_total += xp_needed_for_level(level - 1)
        thresholds[level] = running_total
      end

      thresholds
    end
  end

  def legacy_xp_needed_for_level(level)
    level_value = normalized_level(level)
    return 0 if level_value >= MAX_LEVEL

    (LEGACY_XP_NEEDED_BASE + (LEGACY_XP_NEEDED_LINEAR_FACTOR * level_value)).round
  end

  def legacy_base_xp_for(level)
    level_value = normalized_level(level)

    10 * (1 + Math.log(level_value + 1))
  end
end
