class Api::SpendAgreements::SpendAgreementsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :deal_id,
    :spend_agreement_id,
    :created_at,
    :updated_at
  )

  has_one :spend_agreement, serializer: Api::SpendAgreements::SpendAgreementSerializer
end
