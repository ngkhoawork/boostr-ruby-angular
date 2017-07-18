class AgencyDashboard::ContactsAndRelatedAdvertisersSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser, :email, :phone, :last_touch

  def id
    contact.id
  end

  def name
    contact.name
  end

  def advertiser
    object.account_dimension.as_json(only: [:id, :name])
  end

  def email
    contact.email
  end

  def phone
    contact.phone
  end

  def last_touch
    if contact.latest_happened_activity.any?
      contact.latest_happened_activity.first.happened_at
    end
  end

  def contact
    object.contact
  end
end