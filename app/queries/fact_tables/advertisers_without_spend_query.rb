class FactTables::AdvertisersWithoutSpendQuery

  def initialize(relation = AdvertiserAgencyPipelineFact.joins(:advertiser), options = {})
    @options = options
    @relation = relation
  end

  def call
    advertisers_without_spend
  end

  private

  attr_reader :relation, :options

  def advertisers_without_spend
    relation.joins("LEFT JOIN #{advertisers_seller_sql} ON advertiser_agency_pipeline_facts.advertiser_id = sellers.account_dimension_id")
            .group('account_dimensions.id, account_dimensions.name, sellers.seller_name')
            .where(advertiser_id: matching_ids)
            .order('account_dimensions.name')
            .select('account_dimensions.id, account_dimensions.name as advertiser_name, sellers.seller_name as seller_name, sum(unweighted_amount)')
  end

  def advertisers_seller_sql
    "(SELECT client_id as account_dimension_id, seller_name
      FROM (select client_id, user_id, concat_ws(' ', users.first_name::text, users.last_name::text)
            AS seller_name, max(client_members.share) FROM users
            JOIN client_members ON client_members.user_id = users.id
            AND client_members.share = client_members.share
            GROUP BY seller_name, client_id, user_id) AS max_share_users
     ) AS sellers"
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