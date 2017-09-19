class RemoveAddressFromInfluencer < ActiveRecord::Migration
  def change
    remove_column :influencers, :address
  end
end
