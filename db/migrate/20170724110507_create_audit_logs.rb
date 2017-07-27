class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.string :auditable_type, index: true
      t.integer :auditable_id, index: true
      t.string :type_of_change
      t.string :old_value
      t.string :new_value
      t.string :biz_days
      t.integer :updated_by, index: true
      t.integer :company_id, index: true
      t.integer :user_id, index: true

      t.timestamps null: false
    end
  end
end
