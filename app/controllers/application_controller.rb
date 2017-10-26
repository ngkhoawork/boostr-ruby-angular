class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  after_filter :set_csrf_cookie
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  layout :layout_by_resource
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_admin_user!
    unless current_user && (current_user.is?(:superadmin) || current_user.is?(:supportadmin))
      fail ActionController::RoutingError.new('Not Found')
    end
  end

  def after_sign_in_path_for(user)
    user.starting_page || root_path
  end

  def set_csrf_cookie
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
      response.headers['X-CSRF-TOKEN'] = form_authenticity_token
    end
  end

  def set_current_user
    User.current = current_user
  end

  protected

  def record_not_found
    render json: { message: 'Record not found'}, status: :not_found
  end

  def layout_by_resource
    if devise_controller?
      'devise'
    else
      'application'
    end
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end
end
