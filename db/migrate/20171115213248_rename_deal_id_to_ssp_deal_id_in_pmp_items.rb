class RenameDealIdToSspDealIdInPmpItems < ActiveRecord::Migration
  def change
    rename_column :pmp_items, :deal_id, :ssp_deal_id
  end
end
