class CreateTimePeriods < ActiveRecord::Migration
  def change
    create_table :time_periods do |t|
      t.string :name
      t.integer :company_id
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end
