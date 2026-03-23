class UsernameValidator < ActiveModel::EachValidator
  include ContentUtils

  def validate_each(record, attribute, value)
    return if value.blank?
    return unless contains_banned_word?(value)

    add_forbidden_content_error(record, attribute, message: options[:message] || FORBIDDEN_CONTENT_MESSAGE)
  end
end
