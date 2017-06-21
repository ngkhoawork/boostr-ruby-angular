class FactTables::AccountProductPipelineFacts::FilteredQuery
  def initialize(options = {}, relation = AccountProductPipelineFact.joins(:time_dimension, :product_dimension, account_dimension: [:holding_company]))
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def call
    return relation unless options.any?
    relation.by_time_dimension_date_range(options[:start_date], options[:end_date])
            .by_holding_company_name(options[:holding_company_name])
            .by_account_name(options[:account_name])
            .by_company_id(options[:company_id])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      where('time_dimensions.start_date >= :start_date
             AND time_dimensions.end_date <= :end_date',
             start_date: start_date,
             end_date: end_date)
    end

    def by_account_name(account_name)
      where('account_dimensions.name = :name', name: account_name)
    end

    def by_holding_company_name(holding_company_name)
      where('holding_companies.name = :name', name: holding_company_name)
    end

    def by_company_id(id)
      where('account_product_pipeline_facts.company_id = :id', id: id)
    end
  end
end
