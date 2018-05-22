class CreateSpendAgreements < ActiveRecord::Migration
  def change
    create_table :spend_agreements do |t|
      t.text :name
      t.string :status
      t.string :type
      t.date :start_date
      t.date :end_date
      t.bigint :target, default: 0
      t.boolean :manually_tracked, default: true
      t.references :company, index: true, foreign_key: true
      t.references :holding_company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
