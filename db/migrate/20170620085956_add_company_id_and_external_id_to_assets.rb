class AddCompanyIdAndExternalIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :company, foreign_key: true
  end
end
