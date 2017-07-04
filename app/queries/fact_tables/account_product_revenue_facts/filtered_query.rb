class FactTables::AccountProductRevenueFacts::FilteredQuery
  def initialize(options = {}, relation = AccountProductRevenueFact.joins(:time_dimension, :product_dimension, account_dimension: [:holding_company]))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def call
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:start_date], options[:end_date])
            .by_holding_company_id(options[:holding_company_id])
            .by_account_id(options[:account_id])
            .by_company_id(options[:company_id])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= 31',
             start_date: start_date,
             end_date: end_date)
    end

    def by_account_id(account_id)
      where('account_dimensions.id = :id', id: account_id)
    end

    def by_holding_company_id(holding_company_id)
      where('holding_companies.id = :id', id: holding_company_id)
    end

    def by_company_id(id)
      where('account_product_revenue_facts.company_id = :id', id: id)
    end
  end
end
