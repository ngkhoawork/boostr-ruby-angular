class Api::Contracts::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :company_id,
    :name,
    :restricted,
    :type,
    :status,
    :advertiser,
    :agency,
    :deal
  )

  private

  def type
    object.type&.serializable_hash(only: [:id, :name])
  end

  def status
    object.status&.serializable_hash(only: [:id, :name])
  end

  def advertiser
    object.advertiser&.serializable_hash(only: [:id, :name])
  end

  def agency
    object.agency&.serializable_hash(only: [:id, :name])
  end

  def deal
    object.deal&.serializable_hash(only: [:id, :name])
  end
end
