class AddIsInfluencerProductToProduct < ActiveRecord::Migration
  def change
    add_column :products, :is_influencer_product, :boolean, default: false
  end
end
