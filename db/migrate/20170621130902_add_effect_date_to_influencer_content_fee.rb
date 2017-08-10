class AddEffectDateToInfluencerContentFee < ActiveRecord::Migration
  def change
    add_column :influencer_content_fees, :effect_date, :date
    add_column :influencer_content_fees, :net_loc, :decimal, precision: 15, scale: 2
  end
end
