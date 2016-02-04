class DealIndexSerializer < ActiveModel::Serializer
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
    :deleted_at,
    :advertiser,
    :stage_id,
    :stage)


  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
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
