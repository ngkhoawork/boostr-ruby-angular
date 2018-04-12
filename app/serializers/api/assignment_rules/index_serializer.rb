class Api::AssignmentRules::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :countries, :states, :users, :position, :default

  def users
    object.users.as_json(only: :id, methods: :name, override: true) rescue nil
  end
end
