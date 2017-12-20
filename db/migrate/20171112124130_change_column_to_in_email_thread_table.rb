class ChangeColumnToInEmailThreadTable < ActiveRecord::Migration
  def change
    rename_column :email_threads, :to, :recipient_email
  end
end
