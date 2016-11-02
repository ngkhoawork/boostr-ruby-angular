namespace :users do
  desc "TODO"
  task update_alerts: :environment do
    User.update_all(pos_balance_cnt: 0, neg_balance_cnt: 0, pos_balance: 0, neg_balance: 0, pos_balance_l_cnt: 0, neg_balance_l_cnt: 0, pos_balance_l: 0, neg_balance_l: 0, last_alert_at: DateTime.now)
    User.all.each { |user| user.set_alert(true) }
  end

end
