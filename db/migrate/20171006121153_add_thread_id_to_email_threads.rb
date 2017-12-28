class AddThreadIdToEmailThreads < ActiveRecord::Migration
  def change
    add_column :email_threads, :thread_id, :string
  end
end
