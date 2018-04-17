class Api::DataModelsController < ApplicationController
  def index
    render json: {
        base_model: BaseModelDataMappingSerializer.new(data_model_service.base_klass_const,{current_user: current_user}),
        data_model: ActiveModel::ArraySerializer.new(data_model + custom_model, each_serializer: ModelDataMappingsSerializer,current_user: current_user)
    }
  end

  def data_model
    data_model_service.allowed_reflections
  end

  def custom_model
    WorkflowDataMapping.new("Client").allowed_reflections
  end

  def data_mappings
    mappings = [db_mappings, cf_mappings].flatten!

    render json: mappings, each_serializer: ConfigsDataMappingsSerializer
  end

  def reflections
    render json: DataModels::ReflectionMappings.parsed_json
  end

  def reflections_labels
    render json: DataModels::ReflectionLabelMappings.parsed_json
  end

  private

  def cf_mappings
    custom_fields_mapping_service.mappings_array
  end

  def db_mappings
    DataModels::DbDataMappings.get_mappings(object_name.downcase).map { |mapping| mapping[:name] }
  end

  def custom_fields_mapping_service
    @_cf_service ||= CustomFieldsMappingsSelector.new(object_name, current_user.company_id)
  end

  def data_model_service
    WorkflowDataMapping.new(object_name)
  end

  def client_model_service
    WorkflowDataMapping.new("Client")
  end

  def object_name
    params[:object_name]
  end
end
