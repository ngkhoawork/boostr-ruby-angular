class DealStageLog < ActiveRecord::Base
  belongs_to :company
  belongs_to :deal
  belongs_to :stage
  belongs_to :previous_stage, class_name: 'Stage', foreign_key: 'previous_stage_id'
  belongs_to :stage_updator, class_name: 'User', foreign_key: 'stage_updated_by'

  validates :company_id, :deal_id, :stage_id, :stage_updated_by, :stage_updated_at, presence: true

end
