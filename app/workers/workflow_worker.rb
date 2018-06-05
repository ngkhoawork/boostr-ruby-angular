class WorkflowWorker < BaseWorker
  def perform(opts)
    opts.deep_symbolize_keys!
    deal = Deal.find_by(id: opts[:deal_id])
    type = opts[:type]
    return if deal.blank?
    return if type.blank?
    changed_field = opts[:changed_fields]&.join
    deal.workflows.active.each do |workflow|
      next unless workflow.check_changes('stage_id') if changed_field&.include?('stage_id')

      next unless workflow.switched_on? && workflow.send("fire_on_#{type}")
      WorkflowChainChecker.check(workflow, deal, opts)
    end
  end
end
