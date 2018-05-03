class WorkflowCheckService

  attr_accessor :obj_id, :options, :workflow_criterions, :id, :sql, :event_log, :deal, :workflow_log

  def initialize(obj_id, options, workflow_criterions, id)
    @obj_id = obj_id
    @options = options
    @workflow_criterions = workflow_criterions
    @id = id
  end

  def run_criteria_chain
    select_criteria

    validate_exist_history if deal.blank?

    @event_log = find_by_workflow_id
    @workflow_log = log

    vmc = find_matched_criteria
    if vmc.present?
      return false if vmc.content.map { |c| c.symbolize_keys }.eql?(check_values_in_reflections)
    else
      return create_log unless event_log.present?
      return false if search_ws_states.present?
      update_object(event_log, 'add')
      return true
    end
  end

  def run_check_exist_criteria_chain
    select_criteria
    wf = workflow_criterions.last
    return false if wf.base_object.eql?('Products') && wf.field.eql?('full_name')
    return unless deal.present?
    @event_log = find_by_workflow_id

    if event_log.blank?
      wel = WorkflowEventLog.find_or_create_by(wf_event_log_params)
      wel.deal_workflow_states.create(deal_wf_state_params)
    else
      update_object(event_log, 'add') if search_ws_states.blank?
    end
  end

  def find_by_workflow_id
    WorkflowEventLog.search_wf_events(id, criteria_hash)&.last
  end

  def criteria_hash
    workflow_criterions.map { |wc|
      {
        base_object: wc.base_object,
        field: wc.field,
        math_operator: wc.math_operator,
        value: wc.value,
        relation: wc.relation,
        data_type: wc.data_type
      }
    }.sort_by { |k|
      [k[:base_object], k[:field]]
    }
  end

  def wf_event_log_params
    {
      criteria_hash: criteria_hash,
      deal_ids: [obj_id],
      deal_create: [obj_id],
      deal_update: [obj_id],
      workflow_id: id
    }
  end

  def deal_wf_state_params
    {
      deal_id: obj_id,
      content: check_values_in_reflections,
      workflow_id: id
    }
  end

  def check_values_in_reflections
    workflow_criterions.sort_by { |k|
      [k[:base_object]]
    }.map { |c|
      {
        object: c.base_object,
        c.field.to_sym => deal.first[check_field(c.field)]
      }
    }
  end

  def find_by_workflow_id
    WorkflowEventLog.search_wf_events(id, criteria_hash)&.last
  end

  def find_matched_criteria
    wel = WorkflowEventLog.search_by_deals_criteria_hash(obj_id, criteria_hash)&.last
    return false unless wel.present?
    wel.deal_workflow_states.where(deal_wf_state_params)&.last
  end

  def search_ws_states
    DealWorkflowState.where(workflow_id: id, deal_id: obj_id)
  end

  def select_criteria
    @sql = DealsWorkflowQueryBuilder.new(workflow_criterions, obj_id).get_query
    @deal = Deal.connection.select_all(sql).to_hash
  end

  def update_object(object, action)
    if action.eql?('add')
      object.deal_ids << obj_id
      object.deal_create << obj_id
      object.deal_update << obj_id
      object.save
      object.deal_workflow_states.create(deal_wf_state_params)
      find_matched_criteria
    end
    if action.eql?('remove')
      object.deal_ids.delete_if { |x| x.eql?(obj_id) }
      object.deal_create.delete_if { |x| x.eql?(obj_id) }
      object.deal_update.delete_if { |x| x.eql?(obj_id) }
      object.save
    end
  end

  def validate_exist_history
    search_ws_states&.delete_all
    return false
  end

  def check_field(field)
    return 'curr_cd' if field.eql?('currencies')
    field
  end

  def log
    WorkflowEventLog.search_in_deals_criteria_hash(obj_id, options[:type], criteria_hash, id)&.last
  end

  def create_log
    wel = WorkflowEventLog.create(wf_event_log_params)
    wel.deal_workflow_states.create(deal_wf_state_params)
    return true
  end

end
