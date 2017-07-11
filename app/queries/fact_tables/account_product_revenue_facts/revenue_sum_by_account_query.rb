class FactTables::AccountProductRevenueFacts::RevenueSumByAccountQuery
  def initialize(relation = AccountProductRevenueFact.joins(:time_dimension, :account_dimension))
    @relation = relation
  end

  def call
    relation.group('account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date')
            .order('account_dimensions.name')
            .select('account_dimensions.name, time_dimensions.start_date, sum(revenue_amount)')
  end

  private

  attr_reader :relation
end