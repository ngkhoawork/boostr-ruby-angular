class Workflows::WorkflowableIntegrationsSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :workflow_action_name,
      :workflow_action,
      :workflowable?
  )
end
