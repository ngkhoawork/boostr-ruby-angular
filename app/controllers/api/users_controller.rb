class Api::UsersController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.users
  end

  def update
    if user.update_attributes(user_params)
      render json: user, status: :accepted
    else
      render json: { errors: user.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :title, :email)
  end

  def user
    @user ||= current_user.company.users.where(id: params[:id]).first
  end
end
