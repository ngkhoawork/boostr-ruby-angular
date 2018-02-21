class Pmps::PmpItemDailyActualSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :pmp_item_id,
    :ssp_deal_id,
    :deal,
    :date,
    :ad_unit,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :ad_requests,
    :product,
    :advertiser,
    :ssp_advertiser_id,
    :ssp_advertiser,
    :currency
  )

  def ssp_deal_id
    object.pmp_item.ssp_deal_id rescue nil
  end

  def deal
    object.pmp.deal.serializable_hash(only: [:id, :name]) rescue nil
  end

  def product
    object.pmp_item.product.serializable_hash(only: [:id, :name]) rescue nil
  end

  def ssp_advertiser
    object.ssp_advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def currency
    object.pmp.currency.serializable_hash(only: [:curr_cd, :curr_symbol]) rescue nil
  end
end
