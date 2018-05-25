class Api::V2::CustomFieldNamesController < ApiController
  respond_to :json

  def index
    render json: collection,
           each_serializer: CustomFieldNames::Serializer
  end

  def show
    render json: resource,
           serializer: CustomFieldNames::Serializer
  end

  def create
    if build_resource.save
      render json: resource,
             serializer: CustomFieldNames::Serializer,
             status: :created
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def update
    if resource.update(resource_params)
      render json: resource,
             serializer: CustomFieldNames::Serializer
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if resource.destroy
      render nothing: true,
             status: :no_content
    else
      render json: { errors: resource.errors.messages },
             status: :unprocessable_entity
    end
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
