class AddDeletedAtToSpendAgreements < ActiveRecord::Migration
  def change
    add_column :spend_agreements, :deleted_at, :datetime
  end
end
