class CreateSpendAgreementPublishers < ActiveRecord::Migration
  def change
    create_table :spend_agreement_publishers do |t|
      t.references :publisher, index: true, foreign_key: true
      t.references :spend_agreement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
