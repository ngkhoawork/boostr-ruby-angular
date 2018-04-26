class WorkflowEventLog
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: "workflow_logs"

  has_many :deal_workflow_states

  scope :search_in_deals_criteria_hash, -> (obj_id, type, criteria_hash, id) {
    where(:deal_ids.in => [obj_id], :"deal_#{type}".in => [obj_id],
          criteria_hash: criteria_hash, workflow_id: id)
  }

  scope :search_wf_events, -> (id, criteria_hash) {
    where(workflow_id: id, criteria_hash: criteria_hash)
  }

  scope :search_by_deals_criteria_hash, -> (obj_id, criteria_hash) {
    where(:deal_ids.in => [obj_id], criteria_hash: criteria_hash)
  }

  field :workflow_id, type: Integer
  field :criteria_hash, type: Array, default: []
  field :deal_ids, type: Array, default: []
  field :criteria_sql, type: String
  field :deal_create, type: Array, default: []
  field :deal_update, type: Array, default: []

end
