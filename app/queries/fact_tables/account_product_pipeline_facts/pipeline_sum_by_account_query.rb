class FactTables::AccountProductPipelineFacts::PipelineSumByAccountQuery
  def initialize(relation = AccountProductPipelineFact.joins(:time_dimension, :account_dimension))
    @relation = relation
  end

  def call
    relation.group('account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date')
            .order('account_dimensions.name')
            .select('account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date, sum(weighted_amount) as pipeline_sum')
  end

  private

  attr_reader :relation
end