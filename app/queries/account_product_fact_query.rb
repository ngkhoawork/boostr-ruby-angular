class AccountProductFactQuery

  def initialize(options = {}, relation)
    @relation = relation.extending(FactScopes)
    @options = options
  end

  def call
    return relation unless options.any?
    relation
        .by_time_dimension_date_range(options[:start_date], options[:end_date])
        .by_holding_company_name(options[:holding_company_name])
        .by_account_name(options[:account_name])
  end

  private

  attr_reader :relation, :options

  module FactScopes
    def by_time_dimension_date_range(start_date, end_date)
      joins(:time_dimension).where('time_dimensions.start_date >= :start_date
                                    AND time_dimensions.end_date <= :end_date',
                                   start_date: start_date,
                                   end_date: end_date)

    end

    def by_account_name(account_name)
      joins(:account_dimension).where('account_dimensions.name = :name', name: account_name)
    end

    def by_holding_company_name(holding_company_name)
      joins(account_dimension: [:holding_company]).where('holding_companies.name = :name', name: holding_company_name)
    end
  end

end