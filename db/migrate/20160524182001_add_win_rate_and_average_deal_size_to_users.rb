class AddWinRateAndAverageDealSizeToUsers < ActiveRecord::Migration
  def change
    add_column(:users, :win_rate, :decimal)
    add_column(:users, :average_deal_size, :decimal)
  end
end
