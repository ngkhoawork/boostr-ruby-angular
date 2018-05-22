class ChangeSpendAgreementColTypes < ActiveRecord::Migration
  def change
    unless column_exists? :spend_agreements, :type_id
      add_column :spend_agreements, :type_id, :integer
    end
    unless column_exists? :spend_agreements, :status_id
      add_column :spend_agreements, :status_id, :integer
    end

    remove_column :spend_agreements, :spend_agreement_type, :string
    remove_column :spend_agreements, :status, :string
  end
end
