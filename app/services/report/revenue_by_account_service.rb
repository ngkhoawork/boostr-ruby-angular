# Collects data for 'Revenue by account report'
# Implements following stages:
#   1) Validates input data needed for report processing (raises error if something missed)
#   2) Queries DB with user input filters (with varied options)
#   3) Groups data by month revenues on DB layer (with fixed options)
#   4) Groups data by report headers on ruby layer (with fixed options)
#   5) Sorts data by name asc, team_name asc, seller_names asc, year desc on ruby layer (with fixed options)
#   6) Wraps data into struct objects for a serializer
class Report::RevenueByAccountService
  # DB query settings
  REQUIRED_OPTION_KEYS = %i(company_id start_date end_date).freeze
  OPTIONAL_OPTION_KEYS = %i(client_types category_ids client_region_ids client_segment_ids).freeze
  ALLOWED_OPTION_KEYS = (REQUIRED_OPTION_KEYS + OPTIONAL_OPTION_KEYS).freeze

  # Result data forming settings
  GROUPING_OPTION_KEYS = %i(name category_id client_region_id client_segment_id team_name seller_names year).freeze
  AGGREGATE_OPTION_KEYS = %i(revenues total_revenue).freeze
  INT_MONTHS = { first: 1, last: 12 }.freeze

  def initialize(options)
    options = options.deep_symbolize_keys
    validate_options!(options)

    @options = options
    @options[:start_date] = @options[:start_date].to_date
    @options[:end_date] = @options[:end_date].to_date
  end

  def perform
    query_db
    grouped_data = group_data_by_report_headers
    sorted_data = sort_data(grouped_data)
    build_report_structs(sorted_data)
  end

  private

  def validate_options!(options)
    if (REQUIRED_OPTION_KEYS - options.keys).present?
      raise ArgumentError, "some of required options (#{REQUIRED_OPTION_KEYS.join(', ')}) are missed"
    end
    if (options.keys - ALLOWED_OPTION_KEYS).present?
      raise ArgumentError, "provide only allowed options: #{ALLOWED_OPTION_KEYS.join(', ')}"
    end
  end

  def query_db
    @relation = ScopeBuilder.new(@options).perform
  end

  def group_data_by_report_headers
    @relation.group_by do |record|
      GROUPING_OPTION_KEYS.inject([]) { |acc, name| acc << record.send(name) }
    end.values
  end

  def sort_data(data)
    data.sort_by do |records|
      [records[0].name, records[0].team_name.to_s, records[0].seller_names.to_s, -records[0].year]
    end
  end

  def build_report_structs(records)
    records.inject([]) do |acc, records|
      params = build_report_entity_params(records)
      acc << report_entity_struct.new(*params)
    end
  end

  def report_entity_struct
    @report_entity_struct ||= Struct.new(*report_entity_param_names)
  end

  def report_entity_param_names
    GROUPING_OPTION_KEYS + AGGREGATE_OPTION_KEYS
  end

  # TODO: maybe it's worth to push it out to a distinct builder class
  def build_report_entity_params(records)
    # Fulfill with grouping attributes (common for all records in a group)
    params = GROUPING_OPTION_KEYS.inject([]) { |acc, key| acc << records[0].send(key) }

    # Fulfill with an array of 'sum_revenue_amount' for each month in a given date period
    sum_revenue_amounts = build_month_period_with_zero_amounts(records[0])
    records.each { |r| sum_revenue_amounts[r.month.to_i] = r.sum_revenue_amount }
    params << sum_revenue_amounts

    # Fulfill with a year revenue
    params << sum_revenue_amounts.values.sum
  end

  def build_month_period_with_zero_amounts(record)
    start_month = @options[:start_date].year == record.year ? @options[:start_date].month : INT_MONTHS[:first]
    end_month   = @options[:end_date].year   == record.year ? @options[:end_date].month   : INT_MONTHS[:last]

    (start_month..end_month).inject({}) { |month_period, month| month_period[month] = 0; month_period }
  end

  class ScopeBuilder
    def initialize(options)
      @options = options
    end

    def perform
      aggregate_query(filter_query)
    end

    private

    def filter_query
      FactTables::AccountRevenues::Report::FilteredQuery.new(@options).perform
    end

    def aggregate_query(relation)
      relation
        .joins(:account_dimension, :time_dimension)
        .group(group_condition)
        .select(select_condition)
    end

    def group_condition
      'account_dimensions.name,
       account_revenue_facts.category_id,
       client_region_id,
       client_segment_id,
       team_name,
       seller_names,
       EXTRACT(YEAR FROM start_date),
       EXTRACT(MONTH FROM start_date)'
    end

    def select_condition
      'account_dimensions.name,
       account_revenue_facts.category_id,
       account_revenue_facts.client_region_id,
       account_revenue_facts.client_segment_id,
       team_name,
       seller_names,
       EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
       EXTRACT(MONTH FROM start_date) AS month,
       SUM(revenue_amount) AS sum_revenue_amount'
    end
  end
end
