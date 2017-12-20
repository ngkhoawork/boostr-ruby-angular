class AddLocationFieldToEmailsOpen < ActiveRecord::Migration
  def change
    add_column :email_opens, :location, :string
  end
end
