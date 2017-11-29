class Report::Publishers::AllFieldsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :comscore,
    :website,
    :estimated_monthly_impressions,
    :actual_monthly_impressions,
    :type,
    :publisher_stage,
    :client,
    :teams,
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

  def client
    object.client&.serializable_hash(only: [:id, :name])
  end

  def teams
    object.users.map { |user| user.team&.serializable_hash(only: [:id, :name]) }.compact
  end

  has_one :publisher_custom_field
end
