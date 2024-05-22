class ApplicationController < ActionController::Base
  include AsyncRequestManager
  include ExceptionHandler
  include ParamsHandler
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def utility_code_header
    @utility_code_header ||= request.headers['Utility-ID']
  end

  def utility
    raise ActionController::ParameterMissing, 'Utility-ID header' if utility_code_header.nil?
    utility_code = sanitized_utility_code(utility_code_header)
    @utility ||= Utility.find_by!(code: utility_code)
  end

  def sanitized_utility_code(utility_code_header)
    Integer(utility_code_header)
  rescue ArgumentError
    nil
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '422',
          title: 'Unprocessable Entity',
          detail: resource.errors.messages.values.flatten.first,
          code: '100'
        }
      ]
    }, status: :unprocessable_entity
  end

  def render_resource(resource)
    resource.errors.empty? ? resource_created(resource) : validation_error(resource)
  end

  def resource_created(resource)
    resource_name = resource.class.name.downcase
    message = I18n.t('activerecord.success.create', { resource: I18n.t("activerecord.models.#{resource_name}") })

    render json: { message: message }, status: :created
  end

  def access_denied(exception)
    reset_session
    redirect_to '/admin/login', alert: exception.message
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name document_number])
  end

  def missing_parameters_error
    error_message = I18n.t('activerecord.errors.messages.internal_server_error')
    render json: { error: error_message }, status: :bad_request
  end
end
