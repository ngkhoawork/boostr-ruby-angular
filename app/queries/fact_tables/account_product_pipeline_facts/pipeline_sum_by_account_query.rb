class FactTables::AccountProductPipelineFacts::PipelineSumByAccountQuery
  def initialize(relation = AdvertiserAgencyPipelineFact.joins(:time_dimension, :advertiser))
    @relation = relation
  end

  def perform
    relation.group('account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date')
            .order('account_dimensions.name')
            .select('account_dimensions.name, time_dimensions.start_date, sum(weighted_amount)')
  end

  private

  attr_reader :relation
end