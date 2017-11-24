class Report::Publishers::AllFieldsSerializer < Api::PublisherSerializer
  has_one :publisher_custom_field
end
