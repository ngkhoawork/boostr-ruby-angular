class MoveDealStageLogDataToAuditLogTable < ActiveRecord::Migration
  def change
    DealStageLog.includes(:company, :stage, :previous_stage, :stage_updator).find_each do |deal_stage_log|
      AuditLog.create(
        auditable_type: 'Deal',
        auditable_id: deal_stage_log.deal_id,
        type_of_change: 'Stage Change',
        old_value: deal_stage_log.previous_stage_id,
        new_value: deal_stage_log.stage_id,
        updated_by: deal_stage_log.stage_updated_by,
        company: deal_stage_log.company,
        created_at: deal_stage_log.created_at,
        biz_days: deal_stage_log.active_wday
      )
    end
  end
end
