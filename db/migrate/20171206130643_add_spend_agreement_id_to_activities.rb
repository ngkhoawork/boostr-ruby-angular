class AddSpendAgreementIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :spend_agreement_id, :integer
    add_index :activities, :spend_agreement_id
  end
end
