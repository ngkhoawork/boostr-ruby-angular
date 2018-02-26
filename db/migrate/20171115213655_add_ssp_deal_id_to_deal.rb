class AddSspDealIdToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :ssp_deal_id, :string
  end
end
