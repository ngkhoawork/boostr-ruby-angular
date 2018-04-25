class WorkflowEventLog
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "workflow_logs"

  field :workflow_id, type: Integer
  field :criteria_hash, type: Array, default: []
  field :deal_ids, type: Array, default: []
  field :criteria_sql, type: String
  field :deal_create, type: Array, default: []
  field :deal_update, type: Array, default: []

  index({ workflow_id: 1 }, { unique: true })

end
