# app/controllers/concerns/exception_handler.rb
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :render_incorrect_parameter
    rescue_from ActionController::UnpermittedParameters, with: :render_incorrect_parameter
    rescue_from ActiveRecord::RecordInvalid do |error|
        render_missing_parameter(error)
    end
    rescue_from ActiveRecord::RecordNotFound, with: :render_nothing_not_found
    rescue_from ActiveRecord::StatementInvalid, with: :render_invalid_argument
    rescue_from Exceptions::ClientForbiddenError, with: :render_client_forbidden
    rescue_from Exceptions::ClientUnauthorizedError, with: :render_client_unauthorized
    rescue_from Exceptions::InvalidCurrentClientError do |_exception|
      render_error('invalid_current_client', status: :unprocessable_entity)
    end
    rescue_from Exceptions::UtilityUnavailableError, with: :render_utility_unavailable
    rescue_from Exceptions::InvalidParameterError, with: :render_invalid_parameter
    rescue_from ::ArgumentError, with: :render_invalid_argument
  end

  private

  def render_invalid_parameter(error)
    # The InvalidParameterError exception is raised with the error identifier as a parameter, and
    # the way to access this parameter is by doing error.message
    # render_error(error.message)
    render_error(
      message: I18n.t('activerecord.errors.messages.internal_server_error'),
      meta: error.message,
      status: :bad_request
    )
  end

  def render_incorrect_parameter(error)
    message = I18n.t('activerecord.errors.messages.internal_server_error')

    render_error(
      message: message, meta: error.message, status: :bad_request
    )
  end

  def render_nothing_not_found
    render json: {
      error: I18n.t('activerecord.errors.messages.record_not_found')
    }, status: :not_found
  end

  def render_client_forbidden
    render_error(:client_forbidden, status: :forbidden)
  end

  def render_client_unauthorized
    render_error(:client_unauthorized, status: :unauthorized)
  end

  def render_utility_unavailable
    render_error(:utility_unavailable, status: :internal_server_error)
  end

  def render_invalid_argument(error)
    attribute_name = extract_attribute_name(error.message)
    render json: { errors: [build_error_details(attribute_name)] }, status: :unprocessable_entity
  end

  def extract_attribute_name(message)
    message.split("'").last.split(' ').last
  end

  def build_error_details(attribute_name)
    {
      status: '422',
      title: 'Unprocessable Entity',
      detail: I18n.t(
        "errors.messages.invalid_attribute.#{attribute_name.presence || 'attribute'}"
      ),
      code: '100'
    }
  end

  def render_missing_parameter(error, translation_params = {})
    error_details = build_error_details_for_missing_params(error, translation_params)
    render json: { errors: error_details }, status: :bad_request
  end

  def build_error_details_for_missing_params(error, translation_params)
    error.record.errors.details.flat_map do |attribute, details|
      details.map do |_detail|
        build_single_error_detail(error.record.model_name.singular, attribute, translation_params)
      end
    end
  end

  def build_single_error_detail(model, attribute, translation_params)
    translation_key = "activerecord.errors.#{model}.invalid_attribute.#{attribute}"
    translation = I18n.t(translation_key, **translation_params)
    {
      status: '400',
      title: 'Bad Request',
      detail: translation,
      code: '100'
    }
  end
end
