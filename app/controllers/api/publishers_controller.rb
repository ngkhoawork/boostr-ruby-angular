class Api::PublishersController < ApplicationController
  respond_to :json

  def index
    render json: paginate(filtered_publishers),
           each_serializer: Api::Publishers::IndexSerializer
  end

  def create
    if build_resource.save
      render json: Api::PublisherSerializer.new(resource), status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if resource.update(publisher_params)
      render json: Api::PublisherSerializer.new(resource)
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def settings
    render json: Api::PublisherSettingsSerializer.new(current_user.company)
  end

  private

  def resource
    @resource ||= Publisher.find(params[:id])
  end

  def build_resource
    @resource = Publisher.new(publisher_params)
  end

  def filtered_publishers
    PublishersQuery.new(filter_params).perform
  end

  def filter_params
    params
      .permit(:q, :comscore, :publisher_stage_id, :type_id, :my_publishers_bool, :my_team_publishers_bool)
      .merge(current_user: current_user, company_id: current_user.company_id)
  end

  def publisher_params
    params.require(:publisher).permit(
      :name,
      :comscore,
      :website,
      :estimated_monthly_impressions,
      :actual_monthly_impressions,
      :client_id,
      :publisher_stage_id,
      :type_id,
      address_attributes: [
        :id,
        :country,
        :street1,
        :street2,
        :city,
        :state,
        :zip,
        :phone,
        :mobile,
        :email
      ]
    ).merge(company_id: current_user.company_id)
  end
end
