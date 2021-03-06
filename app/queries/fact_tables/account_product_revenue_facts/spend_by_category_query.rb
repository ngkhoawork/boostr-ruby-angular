class FactTables::AccountProductRevenueFacts::SpendByCategoryQuery
  def initialize(relation = default_relation)
    @relation = relation
  end

  def perform
    relation.find_by_sql(spent_by_category_sql)
  end

  private

  attr_reader :relation

  def default_relation
    AdvertiserAgencyRevenueFact.joins(:account_dimension)
  end

  def spent_by_category_sql
    advertisers_unassigned.union(advertisers_assigned).to_sql
  end

  def advertisers_unassigned
    relation.group('account_dimensions.category_id')
            .where('account_dimensions.category_id is null')
            .select('account_dimensions.category_id, \'Unassigned\' as category_name, sum(revenue_amount)')
  end

  def advertisers_assigned
    relation.joins('INNER JOIN options on options.id = account_dimensions.category_id')
            .group('account_dimensions.category_id, options.name')
            .where('account_dimensions.category_id is not null')
            .select('account_dimensions.category_id, options.name as category_name, sum(revenue_amount)')
  end
end