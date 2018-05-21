class CreateSpendAgreementParentCompanies < ActiveRecord::Migration
  def change
    create_table :spend_agreement_parent_companies do |t|
      t.references :client, index: true, foreign_key: true
      t.references :spend_agreement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
