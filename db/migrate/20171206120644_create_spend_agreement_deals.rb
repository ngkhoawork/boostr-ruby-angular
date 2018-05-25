class CreateSpendAgreementDeals < ActiveRecord::Migration
  def change
    create_table :spend_agreement_deals do |t|
      t.references :deal, index: true, foreign_key: true
      t.references :spend_agreement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
