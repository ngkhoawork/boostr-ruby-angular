class AddGmailFlagToEmailOpen < ActiveRecord::Migration
  def change
    add_column :email_opens, :is_gmail, :boolean, default: false
  end
end
