class Requests::RequestSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :status,
    :description,
    :resolution,
    :due_date,
    :requestable_id,
    :requestable_type,
    :created_at
  )

  has_one :requester, serializer: Requests::UserSerializer
  has_one :assignee, serializer: Requests::UserSerializer
  has_one :deal, serializer: Requests::DealSerializer
  has_one :requestable, serializer: Requests::RequestableSerializer
end
