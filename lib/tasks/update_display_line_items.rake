namespace :display_line_items do
  desc "TODO"
  task update_balance: :environment do
    DisplayLineItem.all.each { |display| display.set_alert(true) }
  end

end
