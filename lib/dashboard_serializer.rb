class DashboardSerializer < ActiveModel::Serializer
  attr_accessor :deals

  attributes(
    :forecast,
    :deals,
  )

  def forecast
    DashboardForecastSerializer.new(object)
  end

  def deals
    @deals.map do |deal|
      DashboardDealSerializer.new(deal)
    end
  end
end

