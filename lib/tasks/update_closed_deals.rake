namespace :deals do
  task update_closed_deals: :environment do
    closed_deals = Deal.closed.where.not(closed_at: nil)
    closed_deals.each do |deal|
      deal_stage_logs = deal.deal_stage_logs
      if deal_stage_logs.any?
        last_stage = deal_stage_logs.last
        deal.update_column(:closed_at, last_stage.created_at)
      else
        deal.update_column(:closed_at, deal.closed_at + 17.hours)
      end
      puts "deal #{deal.id} was updated"
    end
  end
end