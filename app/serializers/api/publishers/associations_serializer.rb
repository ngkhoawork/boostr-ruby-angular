class Api::Publishers::AssociationsSerializer < ActiveModel::Serializer
  attributes(
    :members,
    :contacts
  )

  private

  def members
    object.publisher_members.includes(:user).map do |member|
      Api::Publishers::MembersSerializer.new(member).as_json
    end
  end

  def contacts
    object.contacts.includes(:primary_client_contact, :address).map do |contact|
      Api::Publishers::ContactsSerializer.new(contact).as_json
    end
  end
end
