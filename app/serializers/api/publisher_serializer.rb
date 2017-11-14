class Api::PublisherSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :client_id,
    :created_at,
    :updated_at
  )
end
