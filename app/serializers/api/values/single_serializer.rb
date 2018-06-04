class Api::Values::SingleSerializer < ActiveModel::Serializer
  attributes :id,
             :field_id,
             :option_id
end
