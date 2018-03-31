class DealIndexSerializer < ActiveModel::Serializer
  cached

  has_one :advertiser, serializer: Deals::AdvertiserSerializer
  has_one :agency, serializer: Deals::AgencySerializer

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
    :budget_loc,
    :curr_cd,
    :deal_type,
    :source_type,
    :next_steps,
    :created_by,
    :closed_at,
    :deleted_at,
    :deal_custom_field,
    :stage_id,
    :stage,
    :curr_symbol
  )

  def advertiser
    object.advertiser
  end

  def agency
    object.agency
  end

  def deal_custom_field
    object.deal_custom_field
  end

  def deal_members
    object.users.as_json(override: true, only: [:id], methods: :name)
  end

  def curr_symbol
    object.try(:currency).try(:curr_symbol) rescue '$'
  end

  def cache_key
    parts = []
    parts << object.id
    parts << object.updated_at
    parts << object.advertiser.try(:id)
    parts << object.advertiser.try(:updated_at)
    parts << object.stage.try(:id)
    parts << object.stage.try(:updated_at)
    object.users.each do |user|
      parts << user.id
      parts << user.updated_at
    end
    parts
  end
end

