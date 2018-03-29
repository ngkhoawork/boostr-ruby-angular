class AddColumnSspAdvertisers < ActiveRecord::Migration
  def change
    add_column :pmps, :ssp_advertiser_id, :integer
  end
end
