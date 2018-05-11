require 'awesome_print'

class WorkflowChainChecker
  extend Wisper::Publisher

  def self.check(workflow, deal, options = {})
    # if dynamic query builder query returned at least one record broadcast success
    # to trigger binded action
    workflowable_object_class = deal.class

    # check if workflow criteria chain met requirements for model instance
    if WorkflowCheckService.new(deal.id, options, workflow.id).run_criteria_chain
      ap '=' * 100
      ap 'YES'
      ap '=' * 100
      publish('chain_met_requirements', workflow.id, deal.id, workflowable_object_class, options)
    else
      ap '=' * 100
      ap 'NO'
      ap '=' * 100
      publish('chain_did_not_met_requirements', workflow.id, deal)
    end
  end

  def self.tracking(workflow, deal, options = {})
    WorkflowCheckService.new(deal.id, options, workflow.id).run_check_exist_criteria_chain
  end
end
