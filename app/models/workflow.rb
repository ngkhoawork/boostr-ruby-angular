class Workflow < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :user

  has_one :workflow_action, inverse_of: :workflow, dependent: :destroy

  has_many :workflow_logs
  has_many :workflow_criterions, -> { order(:id) }, inverse_of: :workflow, dependent: :destroy

  validates :name, :workflowable_type, presence: true

  accepts_nested_attributes_for :workflow_action, :workflow_criterions

  scope :for_company, -> (id) { where(company_id: id) }

  def should_integrate?(object_id)
    run_criteria_chain(object_id).any?
  end

  def run_criteria_chain(object_id)
    sql = DealsWorkflowQueryBuilder.new(workflow_criterions, object_id).get_query
    Deal.find_by_sql(sql)
  end
end
