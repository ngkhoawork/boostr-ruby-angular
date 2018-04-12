class WorkflowAction < ActiveRecord::Base
  WORKFLOW_METHODS = ['slack_message'].freeze

  serialize :slack_attachment_mappings, JSON

  belongs_to :workflow, required: true
  belongs_to :api_configuration, required: :true

  validates_presence_of :workflow_type, :workflow_method, :template
  validates_inclusion_of :workflow_type, in: WORKFLOW_METHODS

  def perform_action(workflowable_object = nil, options = {})
    case workflow_type
      when 'slack_message'
        return unless workflowable_object

        options.merge!(attachment_mappings: slack_attachment_mappings)

        message_text = Workflow::MessageBuilder.new(template, workflowable_object).build_message
        attachment_hash = Workflow::AttachmentHashBuilder.new(workflowable_object, options).build


        slack_service.post_message(workflow_method, message_text, attachment: attachment_hash)
      else
        return
    end
  end

  def slack_service
    @_slack_service ||= SlackService.new(SlackApiConfiguration.find(api_configuration_id).password)
  end
end
