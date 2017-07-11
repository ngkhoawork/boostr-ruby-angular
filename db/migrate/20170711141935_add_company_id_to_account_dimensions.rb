class AddCompanyIdToAccountDimensions < ActiveRecord::Migration
  def change
    add_column :account_dimensions, :company_id, :integer
    add_index :account_dimensions, :company_id
  end
end
