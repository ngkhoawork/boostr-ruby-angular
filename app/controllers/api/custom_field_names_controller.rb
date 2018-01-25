class Api::CustomFieldNamesController < ApplicationController
  respond_to :json

  def index
    render json: collection
  end

  def show
    render json: resource
  end

  def create
    if build_resource.save
      render json: resource, status: :created
    else
      render json: { errors: resource.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: resource, status: :ok
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
    current_user.company.custom_field_names.for_model(params[:subject_type].classify)
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
end
