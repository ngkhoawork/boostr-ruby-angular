class FactTables::AccountProductPipelineFacts::FilteredQuery
  def initialize(options = {}, relation = AccountProductPipelineFact.joins(:time_dimension, :product_dimension, :account_dimension)
                                                                    .joins('LEFT JOIN holding_companies
                                                                           ON holding_companies.id = account_dimensions.holding_company_id'))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def call
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:end_date])
            .by_holding_company_id(options[:holding_company_id])
            .by_account_id(options[:account_id])
            .by_company_id(options[:company_id])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date = Date.today.beginning_of_month, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= 31',
             start_date: start_date,
             end_date: end_date)
    end

    def by_account_id(account_id)
      return self unless account_id
      where('account_dimensions.id = :id', id: account_id)
    end

    def by_holding_company_id(holding_company_id)
      return self unless holding_company_id
      where('holding_companies.id = :id', id: holding_company_id)
    end

    def by_company_id(id)
      where('account_product_pipeline_facts.company_id = :id', id: id)
    end
  end
end
