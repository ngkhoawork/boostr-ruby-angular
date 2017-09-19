class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.belongs_to :influencer, index: true, foreign_key: true
      t.string :fee_type
      t.decimal :amount, precision: 15, scale: 2

      t.timestamps null: false
    end
  end
end
