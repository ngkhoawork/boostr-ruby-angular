class FactTables::AdvertisersWithoutSpendQuery

  def initialize(relation = AccountProductPipelineFact.joins(:account_dimension), options = {})
    @options = options
    @relation = relation
  end

  def call
    advertisers_without_spend
  end

  private

  attr_reader :relation, :options

  def advertisers_without_spend
    relation.joins("LEFT JOIN #{advertisers_seller_sql} ON account_product_pipeline_facts.account_dimension_id = sellers.account_dimension_id")
            .group('account_dimensions.id, account_dimensions.name, sellers.seller_name')
            .where(account_dimension_id: advertisers_without_revenue_ids)
            .order('account_dimensions.name')
            .select('account_dimensions.id, account_dimensions.name as advertiser_name, sellers.seller_name as seller_name, sum(unweighted_amount)')
  end

  def advertisers_seller_sql
    "( SELECT client_id as account_dimension_id, seller_name
            FROM (select client_id, user_id, concat_ws(' ', users.first_name::text, users.last_name::text)
                  AS seller_name, max(client_members.share) FROM users
                  JOIN client_members ON client_members.user_id = users.id
                  AND client_members.share = client_members.share
                  GROUP BY seller_name, client_id, user_id) AS max_share_users
          ) AS sellers"
  end

  def matching_ids
    advertiser_ids - advertisers_without_revenue_ids
  end

  def advertisers_without_revenue_ids
    AccountProductRevenueFact.where(account_dimension_id: advertiser_ids).pluck(:account_dimension_id)
  end

  def advertiser_ids
    options[:advertiser_ids]
  end

end