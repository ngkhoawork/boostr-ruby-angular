class FactTables::AccountRevenues::FilteredQuery
  def initialize(options = {}, relation = AccountRevenueFact.joins(:time_dimension, :account_dimension))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:start_date], options[:end_date])
        .by_account_ids(options[:advertiser_ids])
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

    def by_account_ids(account_ids)
      where('account_dimensions.id in (:advertiser_ids)', advertiser_ids: account_ids)
    end

    def by_company_id(id)
      where('account_revenue_facts.company_id = :id', id: id)
    end
  end
end