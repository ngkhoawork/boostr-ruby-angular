class Api::Publishers::AssociationsSerializer < ActiveModel::Serializer
  attributes(
    :members,
    :contacts,
    :member_roles
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

  def member_roles
    object.available_member_roles.as_json(only: [:id, :name])
  end
end
