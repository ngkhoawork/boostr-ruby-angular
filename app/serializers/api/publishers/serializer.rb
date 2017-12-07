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
    :updated_at,
    :publisher_members
  )

  has_one :publisher_stage, serializer: Api::Publishers::StageSerializer

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def publisher_members
    object.publisher_members.includes(:user).map do |member|
      Api::Publishers::MembersSerializer.new(member).as_json
    end
  end
end
