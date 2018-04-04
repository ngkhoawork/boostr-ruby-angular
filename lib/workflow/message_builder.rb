class Workflow::MessageBuilder
  def initialize(message, workflow_object_instance)
    @message = message
    @workflow_object_instance = workflow_object_instance
  end

  def build_message
    normalize_message
    build_message_string
  end

  def message_params_hash
    hash_builder.build
  end

  private

  attr_reader :workflow_object_instance
  attr_accessor :message

  def build_message_string
    template_string_builder.build
  end

  def template_string_builder
    Workflow::TemplateStringBuilder.new(message, message_params_hash)
  end

  def normalize_message
    self.message = Workflow::MessageNormalizer.new(message, parsed_message_params, bo_name).normalize
  end

  def hash_builder
    @_hash_builder ||= Workflow::ParamsHashBuilder.new(parsed_message_params, workflow_object_instance.id, bo_name)
  end

  def parsed_message_params
    @_parsed_message_params ||= WorkflowMessageParser.new(message).get_params_array
  end

  def bo_name
    @_bo_name ||= workflow_object_db_table_name.singularize
  end

  def workflow_object_db_table_name
    @_workflow_object_db_table_name ||= workflow_object_instance.class.table_name
  end

  def workflow_object_instance_class
    workflow_object_instance.class
  end
end
