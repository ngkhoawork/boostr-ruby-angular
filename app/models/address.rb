class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :phone, numericality: { only_integer: true, allow_blank: true }
  validates :mobile, numericality: { only_integer: true, allow_blank: true }

  before_validation do
    self.phone = phone.gsub(/[^0-9]/, '') if attribute_present?('phone')
    self.mobile = mobile.gsub(/[^0-9]/, '') if attribute_present?('mobile')
  end

  scope :contacts_by_email, -> email { where(email: email, addressable_type: "Contact") }
end
