class FactTables::AccountRevenues::Report::FilteredQuery
  def initialize(options = {}, relation = default_relation)
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    relation
      .by_company_id(options[:company_id])
      .by_client_types(options[:client_types])
      .by_time_dimension_date_range(options[:start_date], options[:end_date])
      .by_category_ids(options[:category_ids])
      .by_client_region_ids(options[:client_region_ids])
      .by_client_segment_ids(options[:client_segment_ids])
  end

  private

  attr_reader :relation, :options

  def default_relation
    AccountRevenueFact.all
  end

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      return self unless start_date && end_date

      joins(:time_dimension).where(
        'time_dimensions.start_date >= :start_date
        AND time_dimensions.end_date <= :end_date
        AND time_dimensions.days_length <= 31',
        start_date: start_date,
        end_date: end_date
      )
    end

    def by_account_ids(account_ids)
      account_ids ? joins(:account_dimension).where(account_dimensions: { id: account_ids }) : self
    end

    def by_company_id(company_id)
      company_id ? where(account_revenue_facts: { company_id: company_id }) : self
    end

    def by_client_types(client_type)
      client_type ? joins(:account_dimension).where(account_dimensions: { account_type: client_type }) : self
    end

    def by_category_ids(category_ids)
      category_ids ? where(account_revenue_facts: { category_id: category_ids }) : self
    end

    def by_client_region_ids(client_region_ids)
      return self if client_region_ids.nil?

      joins(:account_dimension).where(account_dimensions: { client_region_id: client_region_ids })
    end

    def by_client_segment_ids(client_segment_ids)
      return self if client_segment_ids.nil?

      joins(:account_dimension).where(account_dimensions: { client_segment_id: client_segment_ids })
    end
  end
end
