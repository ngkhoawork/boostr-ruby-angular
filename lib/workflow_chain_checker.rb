require 'awesome_print'

class WorkflowChainChecker
  extend Wisper::Publisher

  def self.check(workflow_id, model_id, options = {})
    # if dynamic query builder query returned at least one record broadcast success
    # to trigger binded action
    workflow = Workflow.find(workflow_id)
    deal = Deal.find(model_id)
    workflowable_object_class = deal.class

    should_integrate = workflow.should_integrate?(model_id, options)
    ap '============================================'
    ap should_integrate
    ap '============================================'

    # check if workflow criteria chain met requirements for model instance
    if should_integrate
      publish('chain_met_requirements', workflow_id, model_id, workflowable_object_class, options)
    else
      publish('chain_did_not_met_requirements', workflow_id, deal)
    end
  end

  def self.tracking(workflow_id, model_id, options = {})
    workflow = Workflow.find(workflow_id)
    deal = Deal.find(model_id)

    workflow.should_integrate_tracking?(model_id, options)
  end
end
