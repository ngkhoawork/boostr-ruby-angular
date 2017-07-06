class FactTables::AccountProductRevenueFacts::AdvertisersWithoutSpendQuery
  def initialize(relation = AccountProductRevenueFact.joins(:time_dimension, :account_dimension))
    @relation = relation
  end

  def call
    advertisers_without_spend
  end

  private

  attr_reader :relation

  def advertisers_without_spend
    relation.joins("LEFT JOIN #{advertisers_seller_sql} ON account_product_revenue_facts.account_dimension_id = sellers.account_dimension_id")
            .group('account_dimensions.name, sellers.seller_name')
            .order('account_dimensions.name')
            .having('sum(revenue_amount) = 0')
            .select('account_dimensions.name, sellers.seller_name, sum(revenue_amount) as revenue_sum')
  end

  def advertisers_seller_sql
    "SELECT client_id as account_dimension_id, seller_name
     FROM (select client_id, user_id, concat_ws(' ', users.first_name::text, users.last_name::text)
           AS seller_name, max(client_members.share) FROM users
           JOIN client_members ON client_members.user_id = users.id
           AND client_members.share = client_members.share
           GROUP BY seller_name, client_id, user_id) AS max_share_users
     ) AS sellers"
  end
end