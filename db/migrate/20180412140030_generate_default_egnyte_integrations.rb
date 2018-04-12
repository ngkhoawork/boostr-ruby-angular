class GenerateDefaultEgnyteIntegrations < ActiveRecord::Migration
  def change
    company_with_egnyte_integration_ids = Company.joins(:egnyte_integration).pluck(:id)

    Company.where.not(id: company_with_egnyte_integration_ids).each do |company|
      company.create_egnyte_integration!(enabled: false)
    end
  end
end
