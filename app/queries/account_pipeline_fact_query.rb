class AccountPipelineFactQuery < BaseQuery
  def perform
    default_relation
      .by_company_id(options[:company_id])
      .by_time_dimension_id(options[:time_dimension_id])
      .find_by_client_name(options[:client_name])
  end

  private

  def default_relation
    AccountPipelineFact.all.extending(Scopes)
  end

  module Scopes
    def by_company_id(company_id)
      company_id ? where(company_id: company_id) : self
    end

    def by_time_dimension_id(time_dimension_id)
      time_dimension_id ? where(time_dimension_id: time_dimension_id) : self
    end

    def find_by_client_name(client_name)
      client_name ? joins(:account_dimension).where("account_dimensions.name ilike ?", "%#{client_name}%") : self
    end
  end
end
