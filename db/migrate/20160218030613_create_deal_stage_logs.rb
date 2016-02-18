class CreateDealStageLogs < ActiveRecord::Migration
  def change
    create_table :deal_stage_logs do |t|
      t.integer :company_id
      t.integer :deal_id
      t.integer :stage_id
      t.integer :stage_updated_by
      t.datetime :stage_updated_at
      t.string :operation

      t.timestamps null: false
    end
  end
end
