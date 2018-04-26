class DealWorkflowState
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'workflow_deal_states'

  belongs_to :workflow_event_log

  field :deal_id, type: Integer
  field :content, type: Array, default: []
  field :workflow_id, type: Integer

end
