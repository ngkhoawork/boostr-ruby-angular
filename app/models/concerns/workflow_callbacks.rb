require 'active_support/concern'

module WorkflowCallbacks
  extend ActiveSupport::Concern

  included do
    before_destroy { check_chains_for_workflows(on_destroy_workflows, self, destroyed: true, callback_type: "destroy") }
  end

  def check_chains_for_workflows(workflows, model_instance, options = {})
    begin
      return unless model_instance.belongs_to_company?

      workflows.each do |workflow|
        next unless workflow.switched_on?

        WorkflowChainChecker.check(workflow.id, model_instance.id, options) if workflow.send("fire_on_#{options[:callback_type]}")
      end
    rescue => error
    end
  end

  def custom_workflow_update(type)
    workflows.each do |workflow|
      next unless workflow.switched_on?
      WorkflowChainChecker.check(workflow.id, id, {type:type}) if workflow.send("fire_on_#{type}")
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
