class Api::ContractsController < ApplicationController
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

    if params[:file].present?
      import_contracts_csv
      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    else
      if build_resource.save
        render json: resource,
               serializer: permitted_serializer,
               status: :created
      else
        render json: { errors: resource.errors.messages },
               status: :unprocessable_entity
      end
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

    if resource.destroy
      render nothing: true
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def settings
    render json: company,
           serializer: Api::Contracts::SettingsSerializer
  end

  def import_special_terms
    if params[:file].present?
      import_contract_special_terms_csv
      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    end
  end

  private

  def resource
    @resource ||= Contract.find(params[:id])
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
      :days_notice_required,
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
        :client_id,
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

  def import_contracts_csv 
    S3FileImportWorker.perform_async('Importers::ContractsService',
      company.id,
      params[:file][:s3_file_path],
      params[:file][:original_filename])
  end

  def import_contract_special_terms_csv 
    S3FileImportWorker.perform_async('Importers::ContractSpecialTermsService',
      company.id,
      params[:file][:s3_file_path],
      params[:file][:original_filename])
  end
end
