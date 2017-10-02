class CreateAdvertiserAgencyPipelineFacts < ActiveRecord::Migration
  def change
    create_table :advertiser_agency_pipeline_facts do |t|
      t.integer :advertiser_id
      t.integer :agency_id
      t.integer :company_id
      t.integer :time_dimension_id
      t.integer :weighted_amount
      t.integer :unweighted_amount

      t.timestamps null: false
    end
    add_index :advertiser_agency_pipeline_facts, :advertiser_id
    add_index :advertiser_agency_pipeline_facts, :agency_id
    add_index :advertiser_agency_pipeline_facts, :time_dimension_id
    add_index :advertiser_agency_pipeline_facts, :weighted_amount
    add_index :advertiser_agency_pipeline_facts, :unweighted_amount
    add_index :advertiser_agency_pipeline_facts, :company_id
  end
end
