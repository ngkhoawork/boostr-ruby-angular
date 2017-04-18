class CreateContactCfOptions < ActiveRecord::Migration
  def change
    create_table :contact_cf_options do |t|
      t.belongs_to :contact_cf_name, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
