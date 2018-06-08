class AddIndexesForColumnsEmailThreadsAndEmailOpens < ActiveRecord::Migration
  def change
    add_index :email_opens, :guid
    add_index :email_threads, [:user_id, :thread_id]
  end
end
