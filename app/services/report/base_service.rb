# Class and it's subclasses should implement following stages:
#   1) Validates input data needed for report processing (raises error if something missed)
#   2) Queries DB with user input filters (with varied options)
#   3) Groups data by month revenues on DB layer (with fixed options)
#   4) Groups data by report headers on ruby layer (with fixed options)
#   5) Sorts data by name asc, team_name asc, seller_names asc, year desc on ruby layer (with fixed options)
#   6) Wraps data into struct objects for a serializer
class Report::BaseService
  INT_MONTHS = { first: 1, last: 12 }.freeze

  def initialize(params)
    params = params.deep_symbolize_keys
    validate_params!(params)

    @params = params
  end

  def perform
    query_db
    grouped_data = group_data_by_report_headers
    sorted_data = sort_data(grouped_data)
    build_report_items(sorted_data)
  end

  private

  # 1) stage
  def validate_params!(params)
    # Refuse if some of necessary params are absent
    if (required_param_keys - params.keys).present?
      raise ArgumentError, "some of required params (#{required_param_keys.join(', ')}) are missed"
    end
    # Refuse if some of unknown params are present
    if (params.keys - allowed_param_keys).present?
      raise ArgumentError, "provide only allowed params: #{allowed_param_keys.join(', ')}"
    end
  end

  def allowed_param_keys
    @_allowed_param_keys ||= (required_param_keys + optional_param_keys).freeze
  end

  # 2), 3) stages
  def query_db
    @relation = "#{self.class}::ScopeBuilder".constantize.new(@params).perform
  end

  # 4) stage
  def group_data_by_report_headers
    @relation.group_by do |record|
      grouping_keys.inject([]) { |acc, name| acc << record.send(name) }
    end.values
  end

  # 6) stage
  def build_report_items(records)
    records.inject([]) do |acc, records|
      params = build_report_entity_params(records)
      acc << report_entity_struct.new(*params)
    end
  end

  def report_entity_struct
    @report_entity_struct ||= Struct.new(*report_entity_param_names)
  end

  def report_entity_param_names
    @_report_entity_param_names ||= (grouping_keys + aggregating_keys).freeze
  end

  # TODO: maybe it's worth to push it out to a distinct builder class
  def build_report_entity_params(records)
    # Fulfill with grouping attributes (common for all records in a group)
    params = grouping_keys.inject([]) { |acc, key| acc << records[0].send(key) }

    # Fulfill with an array of 'sum_revenue_amount' for each month in a given date period
    sum_revenue_amounts = build_month_period_with_zero_amounts(records[0])
    records.each { |r| sum_revenue_amounts[r.month.to_i] = r.sum_revenue_amount }
    params << sum_revenue_amounts

    # Fulfill with a year revenue
    params << sum_revenue_amounts.values.sum
  end

  def build_month_period_with_zero_amounts(record)
    start_month = @params[:start_date].year == record.year ? @params[:start_date].month : INT_MONTHS[:first]
    end_month   = @params[:end_date].year   == record.year ? @params[:end_date].month   : INT_MONTHS[:last]

    (start_month..end_month).inject({}) { |month_period, month| month_period[month] = 0; month_period }
  end

  # Subclasses must provide implementation for following methods
  %i(
    required_param_keys
    optional_param_keys
    grouping_keys
    aggregating_keys
    sort_data
  ).each do |method|
    define_method(method) do |*_args|
      raise NotImplementedError, "provide implementation for ##{method}"
    end
  end
end
