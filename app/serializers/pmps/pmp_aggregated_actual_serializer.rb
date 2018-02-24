class Pmps::PmpAggregatedActualSerializer < ActiveModel::Serializer
  attributes(
    :date,
    :price,
    :revenue,
    :revenue_loc,
    :impressions,
    :win_rate,
    :ad_requests,
    :advertiser_id,
    :advertiser
  )

  def advertiser_id
    object.advertiser_id rescue nil
  end

  def date
    object.date rescue nil
  end

  def price
    object.price rescue nil
  end

  def impressions
    object.impressions rescue nil
  end

  def win_rate
    object.win_rate rescue nil
  end

  def ad_requests
    object.ad_requests rescue nil
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end
end
