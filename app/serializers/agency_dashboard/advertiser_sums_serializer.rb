class AgencyDashboard::AdvertiserSumsSerializer < ActiveModel::Serializer
  attributes :date, :name, :sum

  def date
    object.start_date.strftime('%m-%Y')
  end

end