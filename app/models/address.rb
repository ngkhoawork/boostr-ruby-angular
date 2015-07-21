class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :phone, numericality: { only_integer: true, allow_blank: true }

  before_validation do
    self.phone = phone.gsub(/[^0-9]/, '') if attribute_present?('phone')
  end
end