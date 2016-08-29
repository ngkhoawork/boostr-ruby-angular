class AddEmailActivityTypeForAllCompanies < ActiveRecord::Migration
  def change
    companies = Company.all
    companies.each do |company|
      ActivityType.create({
          company_id: company.id,
          name: 'Email',
          action: 'emailed with',
          icon:'/assets/icons/email.svg'
                          })
    end
  end
end
