class MoveDealLogDataToAuditLogTable < ActiveRecord::Migration
  def change
    DealLog.includes(deal: :company).find_each do |deal_log|
      AuditLog.create(
        auditable_type: 'Deal',
        auditable_id: deal_log.deal_id,
        type_of_change: 'Budget Change',
        company: Deal.with_deleted.find(deal_log.deal_id).company,
        changed_amount: deal_log.budget_change.to_i,
        created_at: deal_log.created_at
      )
    end
  end
end
