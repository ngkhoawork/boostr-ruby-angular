class Api::CustomFieldNamesController < ApplicationController
  respond_to :json

  def index
    render json: collection, each_serializer: CustomFieldNames::Serializer
  end

  def show
    render json: CustomFieldNames::Serializer.new(resource)
  end

  def create
    if build_resource.save
      render json: CustomFieldNames::Serializer.new(resource), status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: CustomFieldNames::Serializer.new(resource), status: :ok
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    resource.destroy!

    render nothing: true, status: :no_content
  end

  private

  def resource
    @resource ||= collection.find(params[:id])
  end

  def build_resource
    @resource = collection.new(resource_params)
  end

  def collection
    CustomFieldNamesQuery.new(filter_params).perform
  end

  def resource_params
    params
      .require(:custom_field_name)
      .permit(
        :field_type,
        :field_label,
        :is_required,
        :position,
        :show_on_modal,
        :disabled,
        custom_field_options_attributes: [:id, :value]
      )
  end

  def filter_params
    params.merge(company_id: current_user.company_id)
  end
end
