class SetCompanyIdForCustomFields < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.deal_custom_fields.update_all(company_id: company.id)
      company.deal_product_cfs.update_all(company_id: company.id)
      company.account_cfs.update_all(company_id: company.id)
      company.contact_cfs.update_all(company_id: company.id)
    end
  end
end
