class WorkflowWorker < BaseWorker
  def perform(opts)
    opts.deep_symbolize_keys!
    deal = Deal.find_by(id: opts[:deal_id])
    type = opts[:type]
    return if deal.blank?
    return if type.blank?
    deal.workflows.each do |workflow|
      next unless workflow.switched_on? && workflow.send("fire_on_#{type}")
      WorkflowChainChecker.check(workflow, deal, opts)
    end
  end
end
