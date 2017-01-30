class MultiCurrencyIoDealLogValues < ActiveRecord::Migration
  def change
    add_column :ios, :curr_cd, :string, default: 'USD'

    DealLog.update_all('budget_change_loc = budget_change')
  end
end
