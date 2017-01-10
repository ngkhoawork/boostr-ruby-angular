class DealCustomFieldName < ActiveRecord::Base
  belongs_to :company
  scope :by_type, -> type { where(field_type: type) if type.present? }

  after_save :generate_field_index

  def generate_field_index

  end
end
