class CreateQuota < ActiveRecord::Migration
  def change
    create_table :quota do |t|
      t.integer :time_period_id
      t.integer :value
      t.integer :user_id
      t.integer :company_id

      t.timestamps null: false
    end
  end
end
