class Api::RemindersController < ApplicationController
  respond_to :json

  def create
    @reminder = current_user.reminders.new(reminder_params)

    if reminder.save
      render json: reminder, status: :created
    else
      render json: { errors: reminder.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def reminder_params
    params.require(:reminder).permit(:id, :name, :comment, :remindable_id, :remind_on, :remindable_type)
  end

  def reminder
    @reminder ||= current_user.reminders.where(remindable_id: params[:remindable_id])
  end
end
