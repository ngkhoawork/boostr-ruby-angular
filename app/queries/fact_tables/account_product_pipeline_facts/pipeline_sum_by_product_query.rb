class FactTables::AccountProductPipelineFacts::PipelineSumByProductQuery
  def initialize(relation = AccountProductPipelineFact.joins(:time_dimension, :account_dimension, :product_dimension))
    @relation = relation
  end

  def call
    relation.where('time_dimensions.start_date >= ?', Date.today)
            .group('time_dimensions.start_date, time_dimensions.end_date, product_dimensions.name')
            .order('product_dimensions.name')
            .select('time_dimensions.start_date, product_dimensions.name, sum(weighted_amount) as sum')
  end

  private

  attr_reader :relation
end

