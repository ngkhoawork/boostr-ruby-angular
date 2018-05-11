class WorkflowCriteriousHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "workflow_criterious_history"

  field :workflow_id, type: Integer
  field :criteria_hash, type: Array, default: []
end
