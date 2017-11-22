class Api::Publishers::IndexSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :client_id,
    :created_at,
    :updated_at
  )

  has_one :stage, serializer: Api::Publishers::StageSerializer

  private

  def type
    object.type_option&.name
  end

  def stage
    object.publisher_stage
  end
end
