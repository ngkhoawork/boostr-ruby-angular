class FactTables::AccountProductPipelineFacts::PipelineSumByAccountQuery
  def initialize(relation = default_relation)
    @relation = relation
  end

  def perform
    relation.group('advertiser_id, account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date')
            .order('account_dimensions.name')
            .select('advertiser_id, account_dimensions.name, time_dimensions.start_date, sum(weighted_amount)')
  end

  private

  attr_reader :relation

  def default_relation
    AdvertiserAgencyPipelineFact.joins(:time_dimension, :advertiser)
  end
end