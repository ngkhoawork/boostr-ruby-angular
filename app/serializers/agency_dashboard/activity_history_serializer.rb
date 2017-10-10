class AgencyDashboard::ActivityHistorySerializer < ActiveModel::Serializer
  attributes :date, :type, :advertiser, :comments, :contacts

  def date
    object.happened_at
  end

  def type
    object.activity_type_name
  end

  def advertiser
    object.account_dimension.slice('id', 'name')
  end

  def comments
    object.comment
  end

  def contacts
    object.contacts.pluck_to_hash(:id, :name)
  end

end