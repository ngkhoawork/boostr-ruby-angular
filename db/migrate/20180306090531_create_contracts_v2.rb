class CreateContractsV2 < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.references :deal, index: true, foreign_key: true
      t.references :publisher, index: true, foreign_key: true
      t.references :advertiser, references: :clients, index: true
      t.references :agency, references: :clients, index: true
      t.references :type, references: :options, index: true
      t.references :status, references: :options, index: true

      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.decimal :amount, precision: 15, scale: 2
      t.boolean :restricted, null: false, default: false
      t.boolean :auto_renew, null: false, default: false
      t.boolean :auto_notifications, null: false, default: false
      t.string :curr_cd, default: 'USD'
      t.string :name

      t.timestamps null: false
    end

    add_foreign_key :contracts, :clients, column: :advertiser_id
    add_foreign_key :contracts, :clients, column: :agency_id
    add_foreign_key :contracts, :options, column: :type_id
    add_foreign_key :contracts, :options, column: :status_id
  end
end
