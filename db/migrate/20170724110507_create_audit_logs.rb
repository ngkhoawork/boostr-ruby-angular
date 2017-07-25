class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :auditable_type, index: true
      t.integer :auditable_id, index: true
      t.string :changed_field
      t.string :old_value
      t.string :new_value
      t.integer :user_id, index: true
      t.integer :company_id, index: true
      t.integer :deal_member_id, index: true

      t.timestamps null: false
    end
  end
end
