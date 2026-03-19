class ApplicationController < ActionController::Base
  before_action :award_login_badges
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :validation_feedback_data, :validation_field_classes, :validation_field_data

  private

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || dashboard_path
  end

  def award_login_badges
    return unless user_signed_in?
    current_user.award_daily_login
  end

  def configure_permitted_parameters
    extra_keys = %i[name username]

    devise_parameter_sanitizer.permit(:sign_up, keys: extra_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  def validation_feedback_data(record)
    feedback = validation_feedback_for(record)

    {
      controller: "validation-feedback",
      validation_feedback_error_fields_value: feedback[:error_fields].to_json,
      validation_feedback_clear_fields_value: feedback[:clear_fields].to_json,
      validation_feedback_notification_message_value: feedback[:notification_message]
    }
  end

  def validation_field_classes(record, attribute, base_class)
    [base_class, ("error" if validation_error_fields_for(record).include?(attribute.to_s))].compact.join(" ")
  end

  def validation_field_data(attribute)
    {
      validation_feedback_target: "field",
      validation_feedback_field: attribute
    }
  end

  def validation_feedback_for(record)
    forbidden_fields = validation_forbidden_fields_for(record)

    {
      error_fields: validation_error_fields_for(record),
      clear_fields: forbidden_fields,
      notification_message: forbidden_fields.any? ? ContentUtils::FORBIDDEN_CONTENT_NOTIFICATION : ""
    }
  end

  def validation_error_fields_for(record)
    return [] unless record&.respond_to?(:errors)

    record.errors.attribute_names.filter_map do |attribute|
      next if attribute == :base

      validation_attribute_name(record, attribute).to_s
    end.uniq
  end

  def validation_forbidden_fields_for(record)
    return [] unless record&.respond_to?(:errors)

    record.errors.details.filter_map do |attribute, details|
      next if attribute == :base
      next unless details.any? { |detail| detail[:error] == ContentUtils::FORBIDDEN_CONTENT_ERROR }

      validation_attribute_name(record, attribute).to_s
    end.uniq
  end

  def validation_attribute_name(record, attribute)
    return :name if record.is_a?(User) && attribute.to_sym == :username

    attribute.to_sym
  end
end
