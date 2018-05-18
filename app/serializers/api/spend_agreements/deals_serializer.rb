class Api::SpendAgreements::DealsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :deal_id,
    :spend_agreement_id,
    :created_at,
    :updated_at
  )

  has_one :deal, serializer: Api::SpendAgreements::DealSerializer
end
