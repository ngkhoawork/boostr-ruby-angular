class AddInfluencerActiveToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :influencer_enabled, :boolean, default: false
  end
end
