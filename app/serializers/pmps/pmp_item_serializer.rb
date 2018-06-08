class Pmps::PmpItemSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :ssp_deal_id,
    :ssp,
    :budget,
    :budget_loc,
    :budget_delivered,
    :budget_delivered_loc,
    :budget_remaining,
    :budget_remaining_loc,
    :run_rate_7_days,
    :run_rate_30_days,
    :pmp_type,
    :product,
    :total_impressions,
    :total_revenue_loc
  )

  has_one :custom_field, serializer: CustomFields::Serializer

  def ssp
    object.ssp.serializable_hash(only: [:id, :name]) rescue nil
  end

  def product
    if object.pmp.company.product_options_enabled
      object.product
    else
      object.product.serializable_hash(only: [:id, :name]) rescue nil
    end
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
end
