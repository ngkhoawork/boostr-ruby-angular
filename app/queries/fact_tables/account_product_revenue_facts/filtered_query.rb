class FactTables::AccountProductRevenueFacts::FilteredQuery
  def initialize(options = {}, relation = default_relation)
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:start_date], options[:end_date])
            .by_holding_company_id(options[:holding_company_id])
            .by_account_id(options[:account_ids])
            .by_company_id(options[:company_id])
  end

  private

  attr_reader :relation, :options

  def default_relation
    AccountProductRevenueFact
        .joins(:time_dimension, :product_dimension, :account_dimension)
        .joins('LEFT JOIN holding_companies ON holding_companies.id = account_dimensions.holding_company_id')
  end

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= :max_days',
            start_date: start_date,
            end_date: end_date,
            max_days: MAX_DAYS_IN_MONTH)
    end

    def by_account_id(account_ids)
      return self unless account_ids
      where('account_dimensions.id IN (?)', account_ids)
    end

    def by_holding_company_id(holding_company_id)
      return self unless holding_company_id
      where('holding_companies.id = :id', id: holding_company_id)
    end

    def by_company_id(id)
      where('account_product_revenue_facts.company_id = :id', id: id)
    end
  end
end
