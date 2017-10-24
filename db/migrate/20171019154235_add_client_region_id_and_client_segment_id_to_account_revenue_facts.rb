class AddClientRegionIdAndClientSegmentIdToAccountRevenueFacts < ActiveRecord::Migration
  def change
    add_reference :account_revenue_facts, :client_region, index: true
    add_reference :account_revenue_facts, :client_segment, index: true
  end
end
