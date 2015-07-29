class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :advertiser_id
      t.integer :agency_id
      t.integer :company_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.string :stage
      t.integer :budget

      t.timestamps null: false
    end
  end
end
