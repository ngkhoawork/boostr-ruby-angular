class CreateSpendAgreementContacts < ActiveRecord::Migration
  def change
    create_table :spend_agreement_contacts do |t|
      t.references :contact, index: true, foreign_key: true
      t.references :spend_agreement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
