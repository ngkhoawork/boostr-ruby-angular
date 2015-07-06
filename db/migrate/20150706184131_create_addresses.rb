class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :addressable_id
      t.string :addressable_type
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :website
      t.string :phone

      t.timestamps null: false
    end
  end
end
