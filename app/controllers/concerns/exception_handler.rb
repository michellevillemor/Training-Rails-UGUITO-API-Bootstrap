# app/controllers/concerns/exception_handler.rb
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :render_incorrect_parameter
    rescue_from ActionController::UnpermittedParameters, with: :render_incorrect_parameter
    rescue_from ActiveRecord::RecordNotFound, with: :render_nothing_not_found
    rescue_from Exceptions::ClientForbiddenError, with: :render_client_forbidden
    rescue_from Exceptions::ClientUnauthorizedError, with: :render_client_unauthorized
    rescue_from Exceptions::InvalidCurrentClientError do |_exception|
      render_error('invalid_current_client', status: :unprocessable_entity)
    end
    rescue_from Exceptions::UtilityUnavailableError, with: :render_utility_unavailable
    rescue_from Exceptions::InvalidParameterError, with: :render_invalid_parameter
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

  def render_invalid_parameters(error)
    render json: {
      error: I18n.t('activerecord.errors.messages.invalid_attribute'),
      details: error.message
    }, status: :unprocessable_entity
  end

  def render_missing_parameters(error, fields)
    error_details = fields.map do |field|
      {
        status: '400',
        title: 'Bad Request',
        detail: I18n.t("activerecord.errors.#{error.record.model_name.singular}.invalid_attribute.#{field}"),
        code: '400'
      }
    end

    render json: { errors: error_details }, status: :bad_request
  end

  def render_invalid_enums(_error, fields)
    error_details = fields.map do |field|
      {
        status: '422',
        title: 'Unprocessable Entity',
        detail: I18n.t("errors.messages.invalid_attribute.#{field}"),
        code: '422'
      }
    end

    render json: { errors: error_details }, status: :unprocessable_entity
  end
end
