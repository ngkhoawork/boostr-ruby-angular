class Api::UsersController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.users
                                     .by_user_type(user_types)
                                     .order(:id)
  end

  def update
    user.skip_reconfirmation!
    if user.update_attributes(user_params)
      user.roles = params[:roles]
      user.save
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

  def import
    if params[:file].present?
      UsersImportWorker.perform_async(current_user.id,
                                      params[:file][:s3_file_path],
                                      params[:file][:original_filename],
                                      'User')
      render json: {
          message: 'Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)'
      }, status: :ok
    end
  end

  private

  def user_types
    user_type_param.map do |type|
      case type
      when 'seller' then SELLER
      when 'sales_manager' then SALES_MANAGER
      end
    end.compact
  end

  def user_type_param
    if params[:type].kind_of?(Array)
      params[:type]
    else
      [params[:type]]
    end
  end

  def user_params
    user_params = params.require(:user).permit(
      :first_name,
      :last_name,
      :title,
      :team_id,
      :email,
      :notify,
      :win_rate,
      :average_deal_size,
      :cycle_time,
      :starting_page,
      :user_type,
      :is_active,
      :is_legal,
      :default_currency,
      :employee_id,
      :office,
      :agreements_enabled,
      :leads_enabled,
      :contracts_enabled,
      :revenue_requests_access
    )

    if !user_params[:is_active].nil? && current_user.id == user.id
      user_params[:is_active] = true
    end
    user_params
  end

  def starting_page_params
    params.require(:user).permit(:starting_page)
  end

  def user
    @user ||= current_user.company.users.find(params[:id])
  end
end
