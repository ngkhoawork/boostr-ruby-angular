class Pmps::PmpListSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :deal_id,
    :advertiser,
    :agency,
    :budget_loc,
    :start_date,
    :currency
  )

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def currency
    object.currency.serializable_hash(only: [:curr_cd, :curr_symbol]) rescue nil
  end
end
