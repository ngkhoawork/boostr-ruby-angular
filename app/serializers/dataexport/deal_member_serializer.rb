class Dataexport::DealMemberSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :user_id, :share, :role, :created, :last_updated

  def role
    object.values.find_by(field_id: object.fields.find_by_name('Member Role').id)&.option&.name
  end
end
