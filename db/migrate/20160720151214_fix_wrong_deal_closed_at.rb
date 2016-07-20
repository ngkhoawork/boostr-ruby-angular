class FixWrongDealClosedAt < ActiveRecord::Migration
  def change
    deals = Deal.closed
    puts "====Total deals: " + deals.count.to_s
    deals.each do |deal|
      if deal.closed_at.nil? || deal.closed_at.blank?
        deal.closed_at = deal.updated_at
        deal.save!
        puts "====Fixed Deal: " + deal.id.to_s
      end
    end
  end
end
