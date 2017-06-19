class AddHoldingCompanyIdToAccountDimensions < ActiveRecord::Migration
  def change
    add_column :account_dimensions, :holding_company_id, :integer
    add_index :account_dimensions, :holding_company_id
  end
end
