class CreatePublishers < ActiveRecord::Migration
  def change
    create_table :publishers do |t|
      t.string :name, index: true
      t.boolean :comscore, index: true
      t.string :website
      t.integer :estimated_monthly_impressions
      t.integer :actual_monthly_impressions
      t.integer :client_id, index: true

      t.timestamps null: false
    end
  end
end
