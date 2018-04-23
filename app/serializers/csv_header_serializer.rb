class CsvHeaderSerializer < ActiveModel::Serializer
  attributes :id, :field_label

  def field_label
    object.to_csv_header
  end
end
