class CreateDealLogs < ActiveRecord::Migration
  def change
    create_table :deal_logs do |t|
      t.belongs_to :deal, index: true, foreign_key: true
      t.integer :budget_change

      t.timestamps null: false
    end
  end
end
