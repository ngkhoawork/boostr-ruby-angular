class ChangeEmailThreadColumnNames < ActiveRecord::Migration
  def change
    rename_column :email_threads, :email_thread_id, :email_guid
    rename_column :email_opens, :thread_id, :guid
  end
end
