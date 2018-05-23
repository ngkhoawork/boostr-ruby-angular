class Api::AssignmentRules::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :criteria_1, :criteria_2, :users, :position, :default, :field_type

  def users
    object.users.as_json(only: :id, methods: :name, override: true) rescue nil
  end
end
