require 'active_support/concern'

module WorkflowCallbacks
  extend ActiveSupport::Concern

  included do
    after_update { check_chains_for_workflows(on_update_workflows, self, destroyed: false) }
    after_create { check_chains_for_workflows(on_create_workflows, self, destroyed: false) }
    before_destroy { check_chains_for_workflows(on_destroy_workflows, self, destroyed: true) }
  end

  def check_chains_for_workflows(workflows, model_instance, options = {})
    return unless model_instance.belongs_to_company?

    workflows.each do |workflow|
      next unless workflow.switched_on?


      WorkflowChainChecker.check(workflow.id, model_instance.id, options)
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
end