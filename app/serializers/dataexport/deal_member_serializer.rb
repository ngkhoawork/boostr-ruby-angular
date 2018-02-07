class Dataexport::DealMemberSerializer < ActiveModel::Serializer
  attributes :user_id, :share, :role

  def role
    object.values.find_by(field_id: object.fields.find_by_name('Member Role').id)&.option&.name
  end
end
