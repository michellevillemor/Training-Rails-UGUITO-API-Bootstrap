# app/controllers/concerns/exception_handler.rb
module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::UnpermittedParameters, with: :render_incorrect_parameter
    rescue_from ActiveRecord::RecordNotFound, with: :render_nothing_not_found
    rescue_from ActiveRecord::StatementInvalid, with: :render_invalid_parameter
    rescue_from Exceptions::ClientForbiddenError, with: :render_client_forbidden
    rescue_from Exceptions::ClientUnauthorizedError, with: :render_client_unauthorized
    rescue_from Exceptions::InvalidCurrentClientError do |_exception|
      render_error('invalid_current_client', status: :unprocessable_entity)
    end
    rescue_from Exceptions::UtilityUnavailableError, with: :render_utility_unavailable
    rescue_from Exceptions::InvalidParameterError, with: :render_invalid_parameter
    rescue_from ArgumentError, with: :render_invalid_parameter
  end

  private

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

  def render_invalid_parameter(error)
    render json: {
      error: I18n.t('activerecord.errors.messages.invalid_attribute'),
      details: error.message
    }, status: :unprocessable_entity
  end

  def handle_missing_parameter
    render json: {
      error: I18n.t('activerecord.errors.messages.missing_parameter')
    }, status: :bad_request
  end
end
