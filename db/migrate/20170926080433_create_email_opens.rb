class CreateEmailOpens < ActiveRecord::Migration
  def change
    create_table :email_opens do |t|
      t.string :ip
      t.string :device
      t.string :email
      t.string :thread_id
      t.datetime :opened_at

      t.timestamps null: false
    end
  end
end
