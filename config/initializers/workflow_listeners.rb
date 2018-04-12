Rails.application.config.to_prepare do
  Wisper.clear if Rails.env.development?
  WorkflowChainChecker.subscribe(WorkflowEventHandler, async: true)
end
