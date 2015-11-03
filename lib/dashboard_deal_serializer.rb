class DashboardDealSerializer < ActiveModel::Serializer
  cached

  attributes(
    :id,
    :start_date,
    :name,
    :stage)


  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.stage.try(:id)
    parts << object.stage.try(:updated_at)
  end
end

