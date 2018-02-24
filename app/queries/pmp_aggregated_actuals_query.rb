class PmpAggregatedActualsQuery
  attr_accessor :relation, :options, :pmp

  def initialize(options)
    @options = options
    @relation = default_relation.extending(Scopes)
  end

  def perform
    return relation if options.blank?
    relation.group_by(options[:group_by])
            .by_time_period(options[:time_period])
            .by_pmp_item_id(options[:pmp_item_id])
  end

  private

  def default_relation
    @_default_relation ||= pmp.pmp_item_daily_actuals
  end

  def pmp
    @_pmp ||= Pmp.find(options[:pmp_id])
  end

  module Scopes
    def group_by(option)
      return self if option.nil?
      if option == 'date'
        select('
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
      elsif option == 'advertiser'
        select('
          advertiser_id,
          sum(revenue_loc) as revenue_loc,
          sum(revenue) as revenue
        ')
        .group('advertiser_id')
        .where('advertiser_id IS NOT NULL')
      end
    end

    def by_time_period(time_period)
      return self if time_period.nil?
      if time_period == 'last_year'
        where(date: 1.year.ago.beginning_of_year..1.year.ago.end_of_year)
      elsif time_period == 'last_quarter'
        where(date: 3.months.ago.beginning_of_quarter..3.months.ago.end_of_quarter)
      elsif time_period == 'last_month'
        where(date: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
      elsif time_period.to_i > 0
        where(date: time_period.to_i.days.ago..Date.current)
      end
    end

    def by_pmp_item_id(pmp_item_id)
      return self if pmp_item_id.nil?
      if pmp_item_id != 'all'
        where('pmp_item_id = ?', pmp_item_id)       
      else 
        self
      end
    end
  end
end