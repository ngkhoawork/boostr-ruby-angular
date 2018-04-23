class FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery
  def initialize(relation = default_relation)
    @relation = relation
  end

  def perform
    relation.group('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.name')
            .order('product_dimensions.name')
            .select('time_dimensions.start_date, product_dimensions.name, sum(revenue_amount)')
  end

  private

  attr_reader :relation

  def default_relation
    AccountProductRevenueFact.joins(:time_dimension, :account_dimension, :product_dimension)
  end
end