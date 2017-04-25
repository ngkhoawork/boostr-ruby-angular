class Api::V1::RemindersController < ApiController
  respond_to :json

  def index
    render json: user_reminders
  end

  def show
    render json: reminder
  end

  def remindable
    render json: reminder_by_remindable
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
    params.require(:reminder).permit(:id, :name, :comment, :remindable_id, :remind_on, :remindable_type, :completed)
  end

  def reminder_by_remindable
    @reminder ||= Reminder.by_remindable(current_user.id, params[:remindable_id], params[:remindable_type])
  end

  def reminder
    @reminder ||= Reminder.by_id(params[:id], current_user.id).last
  end

  def user_reminders
    @reminder ||= Reminder.user_reminders(current_user.id)
  end
end
