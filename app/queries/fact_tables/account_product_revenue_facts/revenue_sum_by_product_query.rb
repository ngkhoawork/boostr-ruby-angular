class FactTables::AccountProductRevenueFacts::RevenueSumByProductQuery
  def initialize(relation = AccountProductRevenueFact.joins(:time_dimension, :account_dimension, :product_dimension))
    @relation = relation
  end

  def call
    relation.group('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.revenue_type')
            .order('product_dimensions.revenue_type')
            .select('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.revenue_type, sum(revenue_amount) as revenue_sum')
  end

  private

  attr_reader :relation
end