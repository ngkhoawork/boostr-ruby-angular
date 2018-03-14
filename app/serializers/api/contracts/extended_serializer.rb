class Api::Contracts::ExtendedSerializer < Api::Contracts::BaseSerializer
  attributes(
    :description,
    :start_date,
    :end_date,
    :amount,
    :auto_renew,
    :auto_notifications,
    :publisher,
    :currency,
    :contract_members,
    :contract_contacts
  )

  has_many :contract_members, serializer: ContractMembers::BaseSerializer
  has_many :contract_contacts, serializer: ContractContacts::BaseSerializer

  private

  def publisher
    object.publisher&.serializable_hash(only: [:id, :name])
  end

  def currency
    object.currency&.serializable_hash(only: [:curr_cd, :curr_symbol, :name])
  end
end
