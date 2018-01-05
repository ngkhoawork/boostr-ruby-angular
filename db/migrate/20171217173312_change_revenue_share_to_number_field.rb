class ChangeRevenueShareToNumberField < ActiveRecord::Migration
  def change
    change_column :publishers, :revenue_share, 'integer USING CAST(revenue_share AS integer)'
  end
end
