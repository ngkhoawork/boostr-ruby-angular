class Ios::InfluencerContentFeeSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :influencer_id,
    :content_fee_id,
    :fee_type,
    :curr_cd,
    :gross_amount,
    :gross_amount_loc,
    :net,
    :asset,
    :created_at,
    :updated_at,
    :effect_date,
    :net_loc,
    :fee_amount,
    :fee_amount_loc,
    :influencer,
    :content_fee,
  )

  has_one :currency

  def content_fee
    object.content_fee&.serializable_hash(only: [:id], include: { product: { only: [:id, :name] } })
  end

  def influencer
    object.influencer&.serializable_hash(only: [:id, :name], include: :agreement)
  end
end
