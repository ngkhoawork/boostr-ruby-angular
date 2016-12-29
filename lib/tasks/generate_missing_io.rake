namespace :update_deal_status do
  desc "TODO"
  task process_task: :environment do
    Deal.all.each { |deal| deal.set_deal_status }
  end

end
