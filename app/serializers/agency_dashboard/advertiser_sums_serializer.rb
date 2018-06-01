class AgencyDashboard::AdvertiserSumsSerializer < ActiveModel::Serializer
  attributes :advertiser_id, :date, :name, :sum

  def date
    object.start_date.strftime('%Y-%m')
  end

  def sum
    object.sum.to_i
  end

end