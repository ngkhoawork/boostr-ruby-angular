class Api::PublisherSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :stage,
    :client_id,
    :created_at,
    :updated_at
  )

  private

  def type
    object.type_option&.name
  end

  def stage
    object.stage&.name
  end
end
