class FixDealClosedAt < ActiveRecord::Migration
  def change
    deals = Deal.closed.where(closed_at: nil)
    puts "====Total deals: " + deals.count.to_s
    deals.each do |deal|
      deal.closed_at = deal.stage_updated_at.nil? ? deal.updated_at : deal.stage_updated_at
      deal.save!
      puts "====Fixed Deal: " + deal.id.to_s
    end
  end
end
