class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :time_period_id
      t.integer :revenue
      t.integer :weighted_pipeline

      t.timestamps null: false
    end
  end
end
