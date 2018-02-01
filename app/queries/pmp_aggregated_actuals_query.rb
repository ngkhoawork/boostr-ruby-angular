class PmpAggregatedActualsQuery
  def initialize(options)
    @options = options
    @relation = default_relation
  end

  def perform
    return relation if options.blank?
    relation
        .select('
          date,
          sum(price) as price,
          sum(revenue_loc) as revenue_loc,
          sum(revenue) as revenue,
          sum(impressions) as impressions,
          sum(ad_requests) as ad_requests,
          avg(win_rate) as win_rate
        ')
        .group('date')
        .order(:date)
  end

  private

  attr_reader :relation, :options, :pmp

  def default_relation
    @_default_relation ||= pmp.pmp_item_daily_actuals
  end

  def pmp
    @_pmp ||= Pmp.find(options[:pmp_id])
  end
end