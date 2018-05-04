class FactTables::SpendByProductsQuery
  def initialize(revenues, pipelines)
    @revenues = revenues
    @pipelines = pipelines
  end

  def perform
    AccountProductRevenueFact
        .select('start_date, name, sum(sum)')
        .from(unified_data)
        .group('start_date, name')
  end

  private

  attr_reader :revenues, :pipelines

  def unified_data
    [revenues, pipelines].inject(:union)
  end
end