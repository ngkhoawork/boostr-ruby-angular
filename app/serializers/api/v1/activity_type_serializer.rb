class Api::V1::ActivityTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :action, :icon
end
