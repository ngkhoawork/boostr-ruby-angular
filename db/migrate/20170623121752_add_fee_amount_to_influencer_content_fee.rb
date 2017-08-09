class AddFeeAmountToInfluencerContentFee < ActiveRecord::Migration
  def change
    add_column :influencer_content_fees, :fee_amount, :decimal, precision: 15, scale: 2, default: 0
    add_column :influencer_content_fees, :fee_amount_loc, :decimal, precision: 15, scale: 2, default: 0
  end
end
