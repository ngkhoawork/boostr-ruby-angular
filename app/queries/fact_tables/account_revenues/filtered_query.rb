class FactTables::AccountRevenues::FilteredQuery
  def initialize(options = {}, relation = AccountRevenueFact.joins(:time_dimension, :account_dimension))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    return relation unless options.any?
    relation
      .by_time_dimension_date_range(options[:start_date], options[:end_date])
      .by_account_ids(options[:advertiser_ids])
      .by_company_id(options[:company_id])
      .by_category_ids(options[:category_ids])
      .by_client_region_ids(options[:client_region_ids])
      .by_client_segment_ids(options[:client_segment_ids])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      return self unless start_date && end_date

      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= 31',
            start_date: start_date,
            end_date: end_date)
    end

    def by_account_ids(account_ids)
      account_ids ? where(account_dimensions: { id: account_ids }) : self
    end

    def by_company_id(company_id)
      company_id ? where(account_revenue_facts: { company_id: company_id }) : self
    end

    def by_category_ids(category_ids)
      category_ids ? where(account_revenue_facts: { category_id: category_ids }) : self
    end

    def by_client_region_ids(client_region_ids)
      client_region_ids ? where(account_dimensions: { client_region_id: client_region_ids }) : self
    end

    def by_client_segment_ids(client_segment_ids)
      client_segment_ids ? where(account_dimensions: { client_segment_id: client_segment_ids }) : self
    end
  end
end
