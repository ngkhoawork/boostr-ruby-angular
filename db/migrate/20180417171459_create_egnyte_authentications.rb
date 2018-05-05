class CreateEgnyteAuthentications < ActiveRecord::Migration
  def change
    create_table :egnyte_authentications do |t|
      t.references :user, index: true, foreign_key: true

      t.string :state_token
      t.string :access_token

      t.timestamps null: false
    end
  end
end
