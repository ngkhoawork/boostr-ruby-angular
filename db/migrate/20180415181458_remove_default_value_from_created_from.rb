class RemoveDefaultValueFromCreatedFrom < ActiveRecord::Migration
  def change
    change_column_default :clients, :created_from, nil
    change_column_default :contacts, :created_from, nil
    change_column_default :deals, :created_from, nil
  end
end
