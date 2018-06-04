require 'active_support/concern'

module WorkflowCallbacks
  extend ActiveSupport::Concern

  included do
    before_destroy { check_chains_for_workflows(on_destroy_workflows, self, destroyed: true, callback_type: 'destroy') }

    before_update  { track_deal_state if manual_update }
  end

  def check_chains_for_workflows(workflows, deal, options = {})
    begin
      return unless deal.belongs_to_company?

      workflows.each do |workflow|
        next unless workflow.switched_on? && workflow.send("fire_on_#{options[:callback_type]}")
        WorkflowChainChecker.check(workflow, deal, options)
      end
    rescue => error
    end
  end

  def track_deal_state
    workflows.each do |workflow|
      next unless workflow.switched_on?
      WorkflowChainChecker.tracking(workflow, self)
    end
  end

  def belongs_to_company?
    class_belongs_to_associations.include? :company
  end

  def class_belongs_to_associations
    self.class.reflect_on_all_associations(:belongs_to).map(&:name)
  end

  def on_update_workflows
    @_on_update_workflows ||= workflows.where(fire_on_update: true)
  end

  def on_destroy_workflows
    @_on_destroy_workflows ||= workflows.where(fire_on_destroy: true)
  end

  def on_create_workflows
    @_on_create_workflows ||= workflows.where(fire_on_create: true)
  end

  def workflows
    @_workflows ||=  Workflow.for_company(self.company.id).where(workflowable_type: self.class.name)
  end

  def deal_product_state(event_type)
    begin
      opts = {
        deal_id: self.id,
        deal_products_sum: deal_products.sum(:budget),
        event_type: event_type,
        previous_products_sum: self.budget
      }
      DealProductState.create(opts)
    rescue => e
    end
  end
end
