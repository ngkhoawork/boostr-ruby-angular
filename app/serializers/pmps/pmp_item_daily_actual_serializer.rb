class Pmps::PmpItemDailyActualSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :pmp_item_id,
    :ssp_deal_id,
    :date,
    :ad_unit,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :ad_requests,
    :product,
    :ssp_advertiser,
    :advertiser,
    :currency,
    :ssp,
    :pmp
  )

  def revenue
    object.revenue&.to_f
  end

  def revenue_loc
    object.revenue_loc&.to_f
  end

  def ssp_deal_id
    object.pmp_item.ssp_deal_id rescue nil
  end

  def product
    object.pmp_item.product.serializable_hash(only: [:id, :name]) rescue nil
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def currency
    object.pmp.currency.serializable_hash(only: [:curr_cd, :curr_symbol]) rescue nil
  end

  def ssp
    object.pmp_item.ssp.serializable_hash(only: [:id, :name]) rescue nil
  end

  def pmp
    object.pmp.serializable_hash(only: [:id, :name]) rescue nil
  end

  def win_rate
    object.win_rate * 100
  end
end
