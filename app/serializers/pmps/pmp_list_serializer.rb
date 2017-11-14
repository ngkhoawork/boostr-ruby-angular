class Pmps::PmpListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :deal_id,
    :advertiser,
    :agency,
    :budget_delivered,
    :start_date
  )

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

end
