class FactTables::AccountRevenues::FilteredQuery
  # Mapping structure:
  #   {
  #     option_name: { scope_name: [param_names...] },
  #     ...
  #   }
  OPTION_SCOPES_MAPPING = {
    start_date: { by_time_dimension_date_range: [:start_date, :end_date] },
    advertiser_ids: { by_account_ids: [:advertiser_ids] }
  }.freeze

  # Mapping structure:
  #   {
  #     option_name: join_assoc_name,
  #     ...
  #   }
  OPTION_JOINS_MAPPING = {
    start_date: :time_dimension,
    advertiser_ids: :account_dimension
  }.freeze

  def initialize(options = {}, relation = AccountRevenueFact.all)
    options = options.symbolize_keys
    validate_options!(options)

    @relation = relation.extending(FactScopes)
    @options = options
  end

  def perform
    return relation unless options.any?

    apply_necessary_joins
    apply_options
    relation
  end

  private

  attr_accessor :relation
  attr_reader :options

  def validate_options!(options)
    raise ArgumentError, 'provide "end_date" with "start_date"' if options[:start_date] && options[:end_date].nil?
    raise ArgumentError, 'provide "start_date" with "end_date"' if options[:start_date].nil? && options[:end_date]
  end

  def necessary_join_assoc_names
    (OPTION_JOINS_MAPPING.keys & @options.keys).map { |option_name| OPTION_JOINS_MAPPING[option_name] }
  end

  # Apply joins dynamically (only necessary ones)
  def apply_necessary_joins
    necessary_join_assoc_names.each { |join_assoc| self.relation = relation.joins(join_assoc) }
  end

  def apply_options
    options.keys.each do |key|
      self.relation = default_apply_option(key) || specific_apply_option(key) || relation
    end
  end

  # For options which follow 'by_<option_name>' method name conversion
  def default_apply_option(key)
    relation.send(:"by_#{key}", options[key]) if relation.respond_to?(:"by_#{key}")
  end

  # For options which do not follow 'by_<option_name>' method name conversion
  def specific_apply_option(key)
    specific_scope_name = fetch_specific_scope_name(key)

    return unless specific_scope_name && relation.respond_to?(specific_scope_name)

    relation.send(specific_scope_name, *fetch_specific_scope_params(key))
  end

  def fetch_specific_scope_name(option_name)
    OPTION_SCOPES_MAPPING[option_name].try(:keys).try(:first)
  end

  def fetch_specific_scope_params(option_name)
    OPTION_SCOPES_MAPPING[option_name].values[0].inject([]) { |acc, param_name| acc << options[param_name] }
  end

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date
             AND time_dimensions.days_length <= 31',
            start_date: start_date,
            end_date: end_date)
    end

    def by_account_ids(account_ids)
      where(account_dimensions: { id: account_ids })
    end

    def by_company_id(id)
      where(account_revenue_facts: { company_id: id })
    end

    def by_category_ids(id)
      where(account_revenue_facts: { category_id: id })
    end

    def by_client_region_ids(id)
      where(account_revenue_facts: { client_region_id: id })
    end

    def by_client_segment_ids(id)
      where(account_revenue_facts: { client_segment_id: id })
    end
  end
end
