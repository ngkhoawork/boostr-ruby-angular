# Class and it's subclasses should implement following stages:
#   1) Validates input data needed for report processing (raises error if something missed)
#   2) Queries DB with user input filters, aggregates data, paginates data, preloads assocs
#   3) Formats records
class Report::BaseService
  INT_MONTHS = { first: 1, last: 12 }.freeze

  def initialize(params)
    params = params.deep_symbolize_keys
    validate_params!(params)

    @params = params
  end

  def perform
    format_records(query_db)
  end

  private

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

  def query_db
    @relation = "#{self.class}::ScopeBuilder".constantize.new(@params).perform
  end

  %i(
    required_param_keys
    optional_param_keys
    format_records
  ).each do |method|
    define_method(method) do |*_args|
      raise NotImplementedError, "provide implementation for ##{method}"
    end
  end
end
