# Class and it's subclasses should implement following stages:
#   1) Validates input data needed for report processing (raises error if something missed)
#   2) Queries DB with user input filters, aggregates data, paginates data, preloads assocs
class Report::BaseService
  METHODS_FOR_IMPLEMENTATION_IN_SUBCLASSES = %i(required_param_keys optional_param_keys)

  def initialize(params)
    params = params.deep_symbolize_keys
    validate_params!(params)

    @params = params
  end

  def perform
    query_db
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
    scope_builder_class.new(@params).perform
  end

  def scope_builder_class
    "#{self.class}::ScopeBuilder".constantize
  end

  METHODS_FOR_IMPLEMENTATION_IN_SUBCLASSES.each do |method|
    define_method(method) do |*_args|
      raise NotImplementedError, "provide implementation for ##{method}"
    end
  end

  class BaseScopeBuilder
    def initialize(options)
      @options = options
    end

    def perform
      preload_associations(
        paginate(
          apply_filters
        )
      )
    end

    def paginate(relation)
      @options[:page] ? relation.offset(offset).limit(per) : relation
    end

    def per
      @options[:per].to_i > 0 ? @options[:per].to_i : 10
    end

    def offset
      (page - 1) * per
    end

    def page
      @options[:page].to_i > 0 ? @options[:page].to_i : 1
    end
  end
end
