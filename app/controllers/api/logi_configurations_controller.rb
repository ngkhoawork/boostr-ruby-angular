class Api::LogiConfigurationsController < ApplicationController

  def logi_callback
    render json: {data: Logi::BuildAuthorizationUrl.new(current_user, company_id).params }
  end

  private

  def company_id
    current_user.company.id
  end
end