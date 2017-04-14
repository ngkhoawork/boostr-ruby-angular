class CreateCpmBudgetAdjustments < ActiveRecord::Migration
  def change
    create_table :cpm_budget_adjustments do |t|
      t.float :percentage
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
