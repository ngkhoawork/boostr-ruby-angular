class SearchSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :searchable_id,
    :searchable_type,
    :order,
    :details
  )

  def searchable
    object.searchable
  end

  def details
    case object.searchable_type
    when 'Client'
      Search::ClientSerializer.new(searchable)
    when 'Deal'
      Search::DealSerializer.new(searchable)
    when 'Io'
      Search::IoSerializer.new(searchable)
    when 'Contact'
      Search::ContactSerializer.new(searchable)
    when 'Activity'
      searchable
    end
  end
end
