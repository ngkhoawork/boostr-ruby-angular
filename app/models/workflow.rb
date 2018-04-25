class Workflow < ActiveRecord::Base
  belongs_to :company, required: true
  belongs_to :user

  has_one :workflow_action, inverse_of: :workflow, dependent: :destroy

  has_many :workflow_logs
  has_many :workflow_criterions, -> { order(:id) }, inverse_of: :workflow, dependent: :destroy

  validates :name, :workflowable_type, presence: true

  accepts_nested_attributes_for :workflow_action, :workflow_criterions

  scope :for_company, -> (id) { where(company_id: id) }

  attr_accessor :obj_id, :sql, :event_log, :deal, :options

  def should_integrate?(obj_id, options)
    @obj_id = obj_id
    @options = options
    run_criteria_chain.any?
  end

  def run_criteria_chain
    @sql = DealsWorkflowQueryBuilder.new(workflow_criterions, obj_id).get_query

    @deal = Deal.find_by_sql(sql)

    @event_log = find_by_workflow_id

    # remove history if deal already processed by criteria
    vmc = validate_matched_criteria
    if vmc.present? && deal.blank?
      update_object(vmc,'remove')
    end

    if deal.present? && vmc.blank? && options[:type].eql?("update") && created_at < deal.last&.created_at
      if log.blank?
        obj = find_by_workflow_id
        obj.present? ? update_object(obj,"add") : create_log
      end
      return deal
    end

    return [] if deal.blank?
    find_by_workflow_id.blank? ? create_log : update_log
  end

  def update_object(object, action)
    if action.eql?("add")
      object.deal_ids << obj_id
      object.deal_create << obj_id
      object.deal_update << obj_id
    end
    if action.eql?("remove")
      object.deal_ids.delete_if {|x| x.eql?(obj_id) }
      object.deal_create.delete_if {|x| x.eql?(obj_id) }
      object.deal_update.delete_if {|x| x.eql?(obj_id) }
    end
    object.save
  end

  def update_log
    return [] unless log.blank?

    if log.blank?
      obj = find_by_workflow_id
      obj.deal_ids << obj_id unless obj.deal_ids.include?(obj_id)
    else
      obj = log
    end
    obj.deal_create << obj_id unless obj.deal_create.include?(obj_id)
    obj.deal_update << obj_id unless obj.deal_update.include?(obj_id)
    obj.save
    deal
  end

  def validate_matched_criteria
    WorkflowEventLog.where(:deal_ids.in => [obj_id], criteria_hash: criteria_hash)&.last
  end

  def find_by_workflow_id
    WorkflowEventLog.find_by(workflow_id: id)
  end

  def log
    WorkflowEventLog.where(:deal_ids.in => [obj_id],
                           :"deal_#{options[:type]}".in => [obj_id],
                           criteria_hash: criteria_hash,
                           workflow_id: id)&.last
  end

  def create_log
    WorkflowEventLog.create(criteria_hash: criteria_hash,
                            deal_ids: [obj_id],
                            deal_create: [obj_id],
                            deal_update: [obj_id],
                            workflow_id: id)
    deal
  end

  def criteria_hash
    workflow_criterions.map { |wc| {
        base_object: wc.base_object,
        field: wc.field,
        math_operator: wc.math_operator,
        value: wc.value,
        relation: wc.relation,
        data_type: wc.data_type
    } }.sort_by { |k| [k[:base_object], k[:field]] }
  end

end
