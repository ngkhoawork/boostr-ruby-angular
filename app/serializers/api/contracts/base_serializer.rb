class Api::Contracts::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :deal_id,
    :publisher_id,
    :advertiser_id,
    :agency_id,
    :name,
    :description,
    :start_date,
    :end_date,
    :amount,
    :restricted,
    :auto_renew,
    :auto_notifications,
    :type,
    :status,
    :currency
  )

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def status
    object.status&.serializable_hash(only: [:id, :name])
  end

  def currency
    object.currency&.serializable_hash(only: [:curr_cd, :curr_symbol, :name])
  end
end
