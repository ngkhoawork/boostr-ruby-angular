class Api::Publishers::PipelineSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :created_at
  )

  has_many :users, serializer: Api::Publishers::UserSerializer
end
