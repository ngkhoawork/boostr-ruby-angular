class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  after_filter :set_csrf_cookie

  layout :layout_by_resource
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_admin_user!
    unless current_user && current_user.is?(:superadmin)
      fail ActionController::RoutingError.new('Not Found')
    end
  end

  def set_csrf_cookie
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
      response.headers['X-CSRF-TOKEN'] = form_authenticity_token
    end
  end

  protected

  def layout_by_resource
    if devise_controller?
      'devise'
    else
      'application'
    end
  end
end
