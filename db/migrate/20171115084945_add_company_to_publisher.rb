class AddCompanyToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :company_id, :integer 
  end
end
