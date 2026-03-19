module ContentUtils
  FORBIDDEN_CONTENT_ERROR = :forbidden_content
  FORBIDDEN_CONTENT_MESSAGE = "contains forbidden word".freeze
  FORBIDDEN_CONTENT_NOTIFICATION = "Contains forbidden word".freeze

  LEET_TRANSLATIONS = {
    "0" => "o",
    "1" => "i",
    "3" => "e",
    "4" => "a",
    "5" => "s",
    "7" => "t",
    "@" => "a",
    "$" => "s",
    "!" => "i"
  }.freeze

  module_function

  def normalize_for_match(value)
    normalized = I18n.transliterate(value.to_s)
                     .unicode_normalize(:nfkc)
                     .downcase

    LEET_TRANSLATIONS.each do |char, replacement|
      normalized = normalized.gsub(char, replacement)
    end

    normalized.squeeze(" ").strip
  end

  def normalized_words(value)
    normalize_for_match(value)
      .gsub(/[^a-z0-9]+/, " ")
      .squeeze(" ")
      .strip
  end

  def matches_word?(value, word)
    normalized_word = normalize_for_match(word)
    return false if normalized_word.blank?

    if word_like?(normalized_word)
      normalized_words(value).match?(/\b#{Regexp.escape(normalized_word)}\b/)
    else
      normalize_for_match(value).include?(normalized_word)
    end
  end

  def contains_banned_word?(value)
    banned_words.any? { |word| matches_word?(value, word) }
  end

  def add_forbidden_content_error(record, attribute, message: FORBIDDEN_CONTENT_MESSAGE)
    record.errors.add(
      attribute,
      FORBIDDEN_CONTENT_ERROR,
      message: message,
      ui_behavior: FORBIDDEN_CONTENT_ERROR
    )
  end

  def banned_words
    @banned_words ||= begin
      config = Rails.application.config_for(:blacklists_usernames)

      Array(config[:banned_words]).filter_map do |word|
        normalized_word = normalize_for_match(word)
        normalized_word if normalized_word.present?
      end.freeze
    end
  end

  def word_like?(word)
    word.match?(/\A[a-z0-9]+\z/)
  end
end
