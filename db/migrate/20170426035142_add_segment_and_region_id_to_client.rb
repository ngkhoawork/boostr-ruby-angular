class AddSegmentAndRegionIdToClient < ActiveRecord::Migration
  def change
    add_reference :clients, :client_region, index: true
    add_reference :clients, :client_segment, index: true
  end
end
