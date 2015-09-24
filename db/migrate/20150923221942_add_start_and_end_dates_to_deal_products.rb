class AddStartAndEndDatesToDealProducts < ActiveRecord::Migration
  def change
    add_column :deal_products, :start_date, :date
    add_column :deal_products, :end_date, :date

    DealProduct.reset_column_information
    DealProduct.all.each do |deal_product|
      deal_product.start_date = deal_product.period
      deal_product.end_date = deal_product.period.end_of_month
      deal_product.save
    end
  end
end
