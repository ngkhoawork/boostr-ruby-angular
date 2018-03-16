class AddLegalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_legal, :boolean, null: false, default: false
  end
end
