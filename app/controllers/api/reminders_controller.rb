class Api::RemindersController < ApplicationController
  respond_to :json

  def show
    render json: reminder
  end

  def create
    @reminder = current_user.reminders.new(reminder_params)

    if reminder.save
      render json: reminder, status: :created
    else
      render json: { errors: reminder.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if reminder.update_attributes(reminder_params)
      render json: reminder
    else
      render json: { errors: reminder.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    reminder.destroy

    render nothing: true
  end

  private

  def reminder_params
    params.require(:reminder).permit(:name, :comment, :remindable_id, :remind_on, :remindable_type)
  end

  def reminder
    @reminder ||= current_user.reminders.where(remindable_id: params[:id]).last
  end
end
