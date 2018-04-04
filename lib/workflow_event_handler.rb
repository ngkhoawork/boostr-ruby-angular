class WorkflowEventHandler
  def self.chain_met_requirements(workflow_id, object_id, object_class_name, options = {})
    # execute workflow action if chain met requirements
    workflowable_object = object_class_name.find(object_id)
    action = WorkflowAction.find_by(workflow_id: workflow_id)
    action&.perform_action(workflowable_object, options)
  end

  def self.chain_did_not_met_requirements(workflow_id, deal)
    # create workflow log with negative result
  end
end
