class Api::PublisherSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :publisher_stage,
    :client_id,
    :created_at,
    :updated_at
  )

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def publisher_stage
    object.publisher_stage&.name
  end
end
