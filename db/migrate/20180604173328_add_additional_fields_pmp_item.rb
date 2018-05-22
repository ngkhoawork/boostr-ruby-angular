class AddAdditionalFieldsPmpItem < ActiveRecord::Migration
  def change
    unless column_exists? :pmp_items, :without_adv
      add_column :pmp_items, :without_adv, :boolean, default: false
    end
    unless column_exists? :pmp_items, :total_revenue_by_daily_items
      add_column :pmp_items, :total_revenue_by_daily_items, :decimal, precision: 15, scale: 2
    end
    unless column_exists? :pmp_items, :total_impressions_by_daily_items
      add_column :pmp_items, :total_impressions_by_daily_items, :integer
    end
  end
end