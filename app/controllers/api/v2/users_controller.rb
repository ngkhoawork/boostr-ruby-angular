class Api::V2::UsersController < ApiController
  respond_to :json

  def index
    render json: current_user.company.users.order(:id)
  end

  def update
    if user.update_attributes(user_params)
      render json: user, status: :accepted
    else
      render json: { errors: user.errors.messages }, status: :unprocessable_entity
    end
  end

  def starting_page
    if current_user.update_attributes(starting_page_params)
      render json: current_user, status: :accepted
    else
      render json: { errors: current_user.errors.messages }, status: :unprocessable_entity
    end
  end

  def signed_in_user
    render json: current_user, serializer: Users::CompanyInfoSerializer
  end

  private

  def user_params
    user_params = params.require(:user).permit(:first_name, :last_name, :title, :email, :notify, :win_rate, :average_deal_size, :cycle_time, :starting_page, :user_type, :is_active, :default_currency)
    if !user_params[:is_active].nil? && current_user.id == user.id
      user_params[:is_active] = true
    end
    user_params
  end

  def starting_page_params
    params.require(:user).permit(:starting_page)
  end

  def user
    @user ||= current_user.company.users.where(id: params[:id]).first
  end
end
