class RenameTypeToSpendAgreementType < ActiveRecord::Migration
  def change
    rename_column :spend_agreements, :type, :spend_agreement_type
  end
end
