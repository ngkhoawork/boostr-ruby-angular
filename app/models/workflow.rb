require 'awesome_print'
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
  scope :active, -> { where(switched_on: true) }

  attr_accessor :skip_update

  def workflow_event_logs
    return if skip_update
    remove_workflow_history if self.changed? || !md5_signature.eql?(sign)
  end

  def remove_workflow_history
    WorkflowEventLog.where(workflow_id: id)&.delete_all
    DealWorkflowState.where(workflow_id: id)&.delete_all
    self.skip_update = true
    ap "#"*100
    ap "history removed"
    ap "#"*100
    update_attribute(:md5_signature, sign)
  end

  def create_signature
    self.skip_update = true
    update_attribute(:md5_signature, sign)
  end

  def criteria_hash
    critirious = workflow_criterions.map do |wc|
      {
        base_object: wc.base_object,
        field: wc.field,
        math_operator: wc.math_operator,
        value: wc.value,
        relation: wc.relation,
        data_type: wc.data_type
      }
    end
    critirious.sort_by! do |critirio|
      [critirio[:base_object], critirio[:field]]
    end
  end

  def sign
    Digest::MD5.hexdigest(criteria_hash.to_s)
  end

  def should_integrate_tracking?(obj_id, options)
    WorkflowCheckService.new(obj_id, options, workflow_criterions, id).run_check_exist_criteria_chain
  end

end
