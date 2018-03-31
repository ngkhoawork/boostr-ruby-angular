class StatisticSerializer < ActiveModel::Serializer
  attributes :parser_type, :publisher_id, :status, :source, :created_at
end
