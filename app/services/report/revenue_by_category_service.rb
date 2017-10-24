class Report::RevenueByCategoryService
  REQUIRED_OPTION_KEYS = %i(company_id start_date end_date category_id).freeze
  OPTIONAL_OPTION_KEYS = %i(:region_id, :segment_id).freeze
  ALLOWED_OPTION_KEYS = (REQUIRED_OPTION_KEYS + OPTIONAL_OPTION_KEYS).freeze
  GROUPING_OPTION_KEYS = %i(category_id year).freeze
  INT_MONTHS = {
    first: 1,
    last: 12
  }.freeze

  def initialize(options)
    options = options.deep_symbolize_keys
    validate_options!(options)

    @options = options
    @options[:start_date] = @options[:start_date].to_date
    @options[:end_date] = @options[:end_date].to_date
  end

  def perform
    @relation = ScopeBuilder.new(@options).perform

    grouped_records = @relation.group_by do |record|
      GROUPING_OPTION_KEYS.inject([]) { |acc, name| acc << record.send(name) }
    end.values

    result = []
    grouped_records.each do |records|
      params = build_report_entity_params(records)
      result << report_entity_struct.new(*params)
    end

    result
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

  def report_entity_struct
    @report_entity_struct ||= Struct.new(*report_entity_param_names)
  end

  def report_entity_param_names
    GROUPING_OPTION_KEYS + [:revenues, :total_revenue]
  end

  def build_report_entity_params(records)
    # Fulfill with grouping attributes (common for all records in a group)
    params = GROUPING_OPTION_KEYS.inject([]) { |acc, o_n| acc << records[0].send(o_n) }

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
      FactTables::AccountRevenues::FilteredQuery.new(@options).perform
    end

    def aggregate_query(relation)
      relation.group(group_condition).select(select_condition)
    end

    def group_condition
      'account_revenue_facts.category_id, EXTRACT(YEAR FROM start_date), EXTRACT(MONTH FROM start_date)'
    end

    def select_condition
      'account_revenue_facts.category_id,
       EXTRACT(YEAR FROM start_date)::numeric::integer AS year,
       EXTRACT(MONTH FROM start_date) AS month,
       SUM(revenue_amount) AS sum_revenue_amount'
    end
  end
end
