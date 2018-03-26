class Api::ContractsController < ApplicationController
  respond_to :json

  rescue_from ApplicationPolicy::NotAuthorizedError, with: :forbidden_response

  def index
    render json: serialize_collection(by_pages(collection))
  end

  def show
    authorize!(resource)

    render json: resource,
           serializer: permitted_serializer
  end

  def create
    authorize!

    if build_resource.save
      render json: resource,
             serializer: permitted_serializer,
             status: :created
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    authorize!(resource)

    if resource.update(resource_params)
      render json: resource,
             serializer: permitted_serializer
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    authorize!

    resource.destroy

    render nothing: true
  end

  def settings
    render json: company,
           serializer: Api::Contracts::SettingsSerializer
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
      :holding_company_id,
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

  def authorize!(record = nil)
    ::Contracts::ActionsPolicy.new(current_user, record).authorize!(action_name)
  end

  def permitted_serializer(record = nil)
    ::Contracts::SerializersPolicy.new(current_user, record).grand_serializer(action_name)
  end

  def serialize_collection(collection)
    ::Contracts::SerializersPolicy.serialize_collection(current_user, collection)
  end

  def forbidden_response
    render json: { errors: ['Not Authorized'] }, status: :forbidden
  end
end
