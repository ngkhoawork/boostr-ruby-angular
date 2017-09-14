class AddProcessRanAtToAdvertiserAgencyRevenueFacts < ActiveRecord::Migration
  def change
    add_column :advertiser_agency_revenue_facts, :process_ran_at, :datetime
  end
end
