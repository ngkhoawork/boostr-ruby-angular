class Api::ContractsController < ApplicationController
  respond_to :json

  def index
    render json: by_pages(collection),
           each_serializer: Api::Contracts::BaseSerializer
  end

  def show
    render json: resource,
           serializer: Api::Contracts::BaseSerializer
  end

  def create
    if build_resource.save
      render json: resource,
             serializer: Api::Contracts::BaseSerializer,
             status: :created
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: resource,
             serializer: Api::Contracts::BaseSerializer
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    resource.destroy

    render nothing: true
  end

  def settings
    render json: Api::Contracts::SettingsSerializer.new(company)
  end

  private

  def resource
    @resource ||= collection.find(params[:id])
  end

  def collection
    ContractsQuery.new(filter_params).perform
  end

  def company
    current_user.company
  end

  def build_resource
    @resource = Contract.new(resource_params)
  end

  def resource_params
    params.require(:contract).permit(
      :id,
      :deal_id,
      :publisher_id,
      :advertiser_id,
      :agency_id,
      :type_id,
      :status_id,
      :name,
      :description,
      :start_date,
      :end_date,
      :amount,
      :restricted,
      :auto_renew,
      :auto_notifications,
      :curr_cd,
      contract_members_attributes: [:id, :user_id, :role_id, :_destroy],
      contract_contacts_attributes: [:id, :contact_id, :role_id, :_destroy],
      special_terms_attributes: [:id, :name_id, :type_id, :comment, :_destroy]
    ).merge!(company_id: current_user.company_id)
  end

  def filter_params
    params
      .permit(
        :relation,
        :user_id,
        :team_id,
        :advertiser_id,
        :agency_id,
        :deal_id,
        :holding_company_id,
        :type_id,
        :status_id,
        :start_date_start,
        :start_date_end,
        :end_date_start,
        :end_date_end,
        :q
      ).merge(
        company_id: company.id,
        current_user: current_user
      )
  end
end
