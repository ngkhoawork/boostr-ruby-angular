class Api::NotificationsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.notifications
  end

  def update
    if notification.update_attributes(notification_params)
      render json: notification
    else
      render json: { errors: notification.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:notification).permit(:id, :name, :company_id, :subject, :message, :active, :recipients)
  end

  def notification
    @notification ||= current_user.company.notifications.find(params[:id])
  end
end
