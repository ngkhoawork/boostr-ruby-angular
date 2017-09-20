class FactTables::AdvertisersWithoutSpendQuery

  def initialize(relation = AccountRevenueFact.joins(:account_dimensions), options = {})
    @options = options
    @relation = relation
  end

  def call
    advertisers_without_spend
  end

  private

  attr_reader :relation, :options

  def advertisers_without_spend
    relation.group('account_dimensions.id, account_dimensions.name')
            .where(account_dimension_id: matching_ids)
            .order('account_dimensions.name')
            .select('account_dimensions.id, account_dimensions.name as advertiser_name, sum(revenue_amount)')
  end

  def matching_ids
    advertiser_ids - advertisers_with_revenue_ids
  end

  def advertisers_with_revenue_ids
    AdvertiserAgencyRevenueFact.where(advertiser_id: advertiser_ids, agency_id: agencies_ids).uniq.pluck(:advertiser_id)
  end

  def advertiser_ids
    options[:advertiser_ids]
  end

  def agencies_ids
    options[:agencies_ids]
  end

end