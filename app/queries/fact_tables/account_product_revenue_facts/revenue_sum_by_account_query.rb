class FactTables::AccountProductRevenueFacts::RevenueSumByAccountQuery
  def initialize(relation = default_relation)
    @relation = relation
  end

  def perform
    relation.group('advertiser_id, account_dimensions.name, time_dimensions.start_date, time_dimensions.end_date')
            .order('account_dimensions.name')
            .select('advertiser_id, account_dimensions.name, time_dimensions.start_date, sum(revenue_amount)')
  end

  private

  attr_reader :relation

  def default_relation
    AdvertiserAgencyRevenueFact.joins(:advertiser, :time_dimension)
  end
end