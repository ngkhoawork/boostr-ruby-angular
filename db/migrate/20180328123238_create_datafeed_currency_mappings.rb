class CreateDatafeedCurrencyMappings < ActiveRecord::Migration
  def change
    create_table :datafeed_currency_mappings do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.integer :datafeed_curr_id, null: false
      t.string :curr_cd, null: false

      t.timestamps null: false
    end
  end
end
