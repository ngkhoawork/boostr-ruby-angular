class RemoveBudgetFieldsFromEalert < ActiveRecord::Migration
  def change
    remove_column :ealerts, :budget
    remove_column :ealerts, :flight_date
    remove_column :ealerts, :product_name
    remove_column :ealerts, :product_budget
  end
end
