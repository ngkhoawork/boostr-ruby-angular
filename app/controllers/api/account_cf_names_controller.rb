class Api::AccountCfNamesController < ApplicationController
  respond_to :json

  def index
    render json: account_cf_names.order(:position)
                                 .includes(:account_cf_options)
                                 .as_json({include: {
                                   account_cf_options: {
                                     only: [:id, :value]
                                   }
                                 }})
  end

  def show
    render json: account_cf_name
  end

  def update
    if !account_cf_name_params[:account_cf_options_attributes].nil? && account_cf_name_params[:account_cf_options_attributes].count > 0
      option_ids = account_cf_name_params[:account_cf_options_attributes].map{ |option| option[:id] }
      account_cf_name.account_cf_options.where('id NOT IN (?)', option_ids).destroy_all
    else
      account_cf_name.account_cf_options.destroy_all
    end

    if account_cf_name.update_attributes(account_cf_name_params)
      render json: account_cf_name, status: :accepted
    else
      render json: { errors: account_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def create
    account_cf_name = account_cf_names.new(account_cf_name_params)

    if account_cf_name.save
      render json: account_cf_name, status: :created
    else
      render json: { errors: account_cf_name.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    account_cf_name.destroy

    render nothing: true
  end

  def csv_headers
    render json: account_cf_names.order(:position), each_serializer: CsvHeaderSerializer
  end

  private

  def account_cf_name
    @account_cf_name ||= company.account_cf_names.find(params[:id])
  end

  def account_cf_name_params
    params.require(:account_cf_name).permit(
      :field_type, :field_label, :is_required, :position, :show_on_modal, :disabled,
      { account_cf_options_attributes: [:id, :value] }
    )
  end

  def account_cf_names
    @account_cf_names ||= company.account_cf_names
  end

  def company
    @company ||= current_user.company
  end
end
