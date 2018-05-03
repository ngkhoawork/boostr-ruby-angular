class Api::Contracts::ExtendedSerializer < Api::Contracts::BaseSerializer
  attributes(
    :description,
    :start_date,
    :end_date,
    :amount,
    :auto_renew,
    :auto_notifications,
    :publisher,
    :holding_company,
    :currency,
    :contract_members,
    :contract_contacts
  )

  has_many :contract_members, serializer: Api::Contracts::ContractMembers::BaseSerializer
  has_many :contract_contacts, serializer: Api::Contracts::ContractContacts::BaseSerializer
  has_many :special_terms, serializer: Api::Contracts::SpecialTerms::BaseSerializer

  private

  def publisher
    object.publisher&.serializable_hash(only: [:id, :name])
  end

  def holding_company
    object.holding_company&.serializable_hash(only: [:id, :name])
  end

  def currency
    object.currency&.serializable_hash(only: [:curr_cd, :curr_symbol, :name])
  end
end
