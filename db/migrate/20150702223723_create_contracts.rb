class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :license_id
      t.integer :company_id

      t.timestamps null: false
    end
  end
end
