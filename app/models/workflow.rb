class Workflow < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :user

  after_create :create_signature
  after_update :workflow_event_logs

  has_one :workflow_action, inverse_of: :workflow, dependent: :destroy

  has_many :workflow_logs
  has_many :workflow_criterions, -> { order(:id) }, inverse_of: :workflow, dependent: :destroy

  validates :name, :workflowable_type, presence: true

  accepts_nested_attributes_for :workflow_action, :workflow_criterions

  scope :for_company, -> (id) { where(company_id: id) }

  def workflow_event_logs
    remove_workflow_history if self.changed? || !md5_signature.eql?(sign)
  end

  def remove_workflow_history
    WorkflowEventLog.where(workflow_id: id)&.delete_all
    DealWorkflowState.where(workflow_id: id)&.delete_all
  end

  def create_signature
    update_attribute(:md5_signature, sign)
  end

  def sign
    sign = workflow_criterions.order(created_at: :desc).pluck(:created_at).join
    Digest::MD5.hexdigest(sign)
  end

  def should_integrate?(obj_id, options)
    WorkflowCheckService.new(obj_id, options, workflow_criterions, id).run_criteria_chain
  end

  def should_integrate_tracking?(obj_id, options)
    WorkflowCheckService.new(obj_id, options, workflow_criterions, id).run_check_exist_criteria_chain
  end

end
