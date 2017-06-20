class AddEmployeeIdAndOfficeColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :employee_id, :string, limit: 20
    add_column :users, :office, :string, limit: 100
  end
end
