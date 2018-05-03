class AddHoldingCompanyIdAndDeletedAtToContracts < ActiveRecord::Migration
  def change
    add_reference :contracts, :holding_company, foreign_key: true, index: true

    add_column :contracts, :deleted_at, :datetime
    add_index :contracts, :deleted_at
  end
end
