class Api::SpendAgreements::TeamMemberSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :role,
    :user_id,
    :spend_agreement_id,
    :created_at,
    :updated_at
  )

  has_one :user, serializer: Api::SpendAgreements::UserSerializer
  has_many :values, serializer: Api::Values::SingleSerializer

  def role
    object.value_from_field(@options[:role])
  end
end
