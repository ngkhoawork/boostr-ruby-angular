class Contracts::SerializersPolicy < ApplicationPolicy
  def self.serialize_collection(user, collection)
    collection.map do |record|
      serializer = new(user, record).grand_serializer(:index)
      serializer.new(record).as_json
    end
  end

  def grand_serializer(action)
    raise ArgumentError, 'Undefined action' unless allowed_actions.include?(action.to_sym)

    send("#{action}_serializer")
  end

  private

  def index_serializer
    if (record.restricted? && user.is_not_legal?)
      Api::Contracts::RestrictedSerializer
    else
      Api::Contracts::BaseSerializer
    end
  end

  def create_serializer
    Api::Contracts::ExtendedSerializer
  end

  def update_serializer
    create_serializer
  end

  def show_serializer
    create_serializer
  end

  def destroy_serializer
    create_serializer
  end
end
