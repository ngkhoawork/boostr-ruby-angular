class AddPmpSspAdvertiserColumn < ActiveRecord::Migration
  def change
    unless column_exists? :pmps, :ssp_advertiser_id
      add_column :pmps, :ssp_advertiser_id, :integer
    end
  end
end
