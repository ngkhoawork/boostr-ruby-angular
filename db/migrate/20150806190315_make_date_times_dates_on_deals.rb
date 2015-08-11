class MakeDateTimesDatesOnDeals < ActiveRecord::Migration
  def change
    change_column :deals, :start_date, :date
    change_column :deals, :end_date, :date
  end
end
