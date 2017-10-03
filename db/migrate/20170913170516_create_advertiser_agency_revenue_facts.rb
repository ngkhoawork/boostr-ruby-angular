class CreateAdvertiserAgencyRevenueFacts < ActiveRecord::Migration
  def change
    create_table :advertiser_agency_revenue_facts do |t|
      t.integer :advertiser_id
      t.integer :agency_id
      t.integer :company_id
      t.integer :time_dimension_id
      t.integer :revenue_amount

      t.timestamps null: false
    end
    add_index :advertiser_agency_revenue_facts, :advertiser_id
    add_index :advertiser_agency_revenue_facts, :agency_id
    add_index :advertiser_agency_revenue_facts, :time_dimension_id
    add_index :advertiser_agency_revenue_facts, :revenue_amount
    add_index :advertiser_agency_revenue_facts, :company_id
  end
end
