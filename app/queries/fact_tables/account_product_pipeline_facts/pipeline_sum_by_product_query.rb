class FactTables::AccountProductPipelineFacts::PipelineSumByProductQuery
  def initialize(relation = AccountProductPipelineFact.joins(:time_dimension, :account_dimension, :product_dimension))
    @relation = relation
  end

  def call
    relation.where('time_dimensions.start_date > ?', Date.today)
            .group('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.revenue_type')
            .order('product_dimensions.revenue_type')
            .select('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.revenue_type, sum(weighted_amount) as pipeline_sum')
  end

  private

  attr_reader :relation
end

