class AddStartingPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :starting_page, :string
  end
end
