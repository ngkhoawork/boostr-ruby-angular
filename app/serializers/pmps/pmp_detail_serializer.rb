class Pmps::PmpDetailSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :deal_id,
    :advertiser,
    :agency,
    :budget,
    :budget_loc,
    :currency,
    :budget_delivered,
    :budget_remaining,
    :start_date,
    :end_date
  )

  has_many :pmp_members, serializer: Pmps::PmpMemberSerializer
  has_many :pmp_items, serializer: Pmps::PmpItemSerializer

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
