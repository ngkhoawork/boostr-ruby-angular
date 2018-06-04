class Pmps::PmpItemDailyActualGroupedSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :pmp_id,
    :deal_id,
    :ssp_deal_id,
    :pmp,
    :ssp,
    :advertiser,
    :total_impressions,
    :total_revenue_loc,
    :count,
    :actuals_last
  )

  delegate :ssp_deal_id, :pmp, :ssp, to: :object

  def pmp_id
    object.id
  end

  def deal_id
    object.ssp_deal_id
  end

  def advertiser
    advertisers = actuals.pluck(:ssp_advertiser).uniq
    advertisers.size > 1 ? 'Multiple' : advertisers.last
  end

  def actuals
    @_actuals ||= object.pmp_item_daily_actuals.where(advertiser_id: nil )
        .where.not(revenue: 0.0)
  end

  def total_impressions
    actuals.sum(:impressions)&.to_f
  end

  def total_revenue_loc
    actuals.sum(:revenue)&.to_f
  end

  def count
    actuals.count
  end

  def actuals_last
    actuals.last
  end

end
