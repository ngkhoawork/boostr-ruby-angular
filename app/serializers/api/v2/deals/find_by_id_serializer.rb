class Api::V2::Deals::FindByIdSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser, :agency

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name])
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name])
  end
end
