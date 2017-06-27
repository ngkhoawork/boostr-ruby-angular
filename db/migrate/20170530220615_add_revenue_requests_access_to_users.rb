class AddRevenueRequestsAccessToUsers < ActiveRecord::Migration
  def change
    add_column :users, :revenue_requests_access, :boolean, default: false
  end
end
