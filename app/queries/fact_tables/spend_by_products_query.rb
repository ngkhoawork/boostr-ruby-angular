class FactTables::SpendByProductsQuery
  def initialize(revenues, pipelines)
    @revenues = revenues
    @pipelines = pipelines
  end

  def perform
    AccountProductRevenueFact
        .select('start_date, top_parent_id, sum(sum)')
        .from(unified_data)
        .group('start_date, top_parent_id')
  end

  private

  attr_reader :revenues, :pipelines

  def unified_data
    [revenues, pipelines].inject(:union)
  end
end