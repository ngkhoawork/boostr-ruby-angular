class Api::Publishers::Serializer < ActiveModel::Serializer
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

  has_one :publisher_stage, serializer: Api::Publishers::StageSerializer
  has_many :publisher_members, serializer: Api::Publishers::MembersSerializer

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end
end
