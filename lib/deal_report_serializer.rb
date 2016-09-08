class DealReportSerializer < ActiveModel::Serializer
  cached

  attributes(
    :id,
    :advertiser_id,
    :agency_id,
    :company_id,
    :start_date,
    :end_date,
    :name,
    :budget,
    :deal_type,
    :source_type,
    :next_steps,
    :created_by,
    :created_at,
    :deleted_at,
    :closed_at,
    :advertiser,
    :stage_id,
    :stage,
    :agency,
    :deal_products,
    :users,
    :close_reason
  )

  def stage
    object.stage.serializable_hash(only: [:id, :name, :probability]) rescue nil
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def users
    object.users.map {|user| user.serializable_hash(only: [:id, :first_name, :last_name]) rescue nil}
  end

  def deal_products
    object.deal_products.map {|deal_product| deal_product.serializable_hash(only: [:id, :budget, :start_date, :end_date]) rescue nil}
  end

  def close_reason
    Deal.get_option(object, "Close Reason")
  end

  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.advertiser.try(:id)
    parts << object.advertiser.try(:updated_at)
    parts << object.stage.try(:id)
    parts << object.stage.try(:updated_at)
    parts << object.agency.try(:id)
    parts << object.agency.try(:updated_at)
    parts << object.users.try(:id)
    parts << object.users.try(:updated_at)
    parts << object.deal_products.try(:id)
    parts << object.deal_products.try(:updated_at)
    parts
  end
end

