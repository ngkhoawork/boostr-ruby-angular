class CreateEmailThreads < ActiveRecord::Migration
  def change
    create_table :email_threads do |t|
      t.string :email_thread_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
