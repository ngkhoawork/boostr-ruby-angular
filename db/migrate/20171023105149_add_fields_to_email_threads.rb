class AddFieldsToEmailThreads < ActiveRecord::Migration
  def change
    add_column :email_threads, :body, :string
    add_column :email_threads, :subject, :string
    add_column :email_threads, :to, :string
    add_column :email_threads, :from, :string
    add_column :email_threads, :sender, :string
    add_column :email_threads, :recipient, :string
  end
end
