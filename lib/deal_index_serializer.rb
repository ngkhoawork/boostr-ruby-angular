class DealIndexSerializer < ActiveModel::Serializer
  cached

  attributes(
    :id,
    :advertiser_id,
    :agency_id,
    :company_id,
    :deal_members,
    :start_date,
    :end_date,
    :name,
    :budget,
    :curr_cd,
    :deal_type,
    :source_type,
    :next_steps,
    :created_by,
    :closed_at,
    :deleted_at,
    :advertiser,
    :agency,
    :deal_custom_field,
    :stage_id,
    :stage)


  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def deal_custom_field
    object.deal_custom_field
  end

  def deal_members
    object.users.as_json(override: true, only: [:id], methods: :name)
  end

  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.advertiser.try(:id)
    parts << object.advertiser.try(:updated_at)
    parts << object.stage.try(:id)
    parts << object.stage.try(:updated_at)
    parts
  end
end

