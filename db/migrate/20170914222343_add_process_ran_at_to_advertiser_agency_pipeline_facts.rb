class AddProcessRanAtToAdvertiserAgencyPipelineFacts < ActiveRecord::Migration
  def change
    add_column :advertiser_agency_pipeline_facts, :process_ran_at, :datetime
  end
end
