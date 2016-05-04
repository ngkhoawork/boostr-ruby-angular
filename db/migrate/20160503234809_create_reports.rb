class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :time_period_id
      t.string :name
      t.integer :value

      t.timestamps null: false
    end
  end
end
