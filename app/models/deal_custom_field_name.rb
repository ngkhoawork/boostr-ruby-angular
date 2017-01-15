class DealCustomFieldName < ActiveRecord::Base
  belongs_to :company
  scope :by_type, -> type { where(field_type: type) if type.present? }

  def self.get_field_limit(type)
    puts "====="
    puts type
    field_limits = {
        "currency" => 7,
        "text" => 5,
        "note" => 2,
        "datetime" => 7,
        "number" => 7,
        "integer" => 7,
        "boolean" => 3,
        "percentage" => 5
    }
    field_limits[type]
  end
end
