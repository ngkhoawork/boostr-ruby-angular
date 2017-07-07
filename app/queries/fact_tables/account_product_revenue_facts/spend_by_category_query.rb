class FactTables::AccountProductRevenueFacts::SpendByCategoryQuery
  def initialize(relation = AccountProductRevenueFact.joins(:account_dimension))
    @relation = relation
  end

  def call
    relation.find_by_sql(spent_by_category)
  end

  private

  attr_reader :relation

  def spent_by_category_sql
    advertisers_unassigned.union(advertisers_assigned).to_sql
  end

  def advertisers_unassigned
    relation.joins('INNER JOIN options on options.id = account_dimensions.category_id')
            .group('account_dimensions.category_id')
            .where('account_dimensions.category_id is null')
            .select('account_dimensions.category_id, null as category_name, sum(revenue_amount) as revenue_sum')
  end

  def advertisers_assigned
    relation.joins('INNER JOIN options on options.id = account_dimensions.category_id')
            .group('account_dimensions.category_id, options.name')
            .where('account_dimensions.category_id is not null')
            .select('account_dimensions.category_id, options.name as category_name, sum(revenue_amount) as revenue_sum')
  end
end