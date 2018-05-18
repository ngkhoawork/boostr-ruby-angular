class CreateHooplaUsers < ActiveRecord::Migration
  def change
    create_table :hoopla_users do |t|
      t.string :href
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end
