class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :phone, numericality: { only_integer: true, allow_blank: true }
  validates :mobile, numericality: { only_integer: true, allow_blank: true }
  validate :us_state

  before_validation do
    self.phone = phone.gsub(/[^0-9]/, '') if attribute_present?('phone')
    self.mobile = mobile.gsub(/[^0-9]/, '') if attribute_present?('mobile')
  end

  def us_state
    if state.present?
      states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']
      unless states.include?(state)
        errors.add(:state, "has the wrong format")
      end
    end
  end

  scope :contacts_by_email, -> email { where(email: email, addressable_type: "Contact") }
end
