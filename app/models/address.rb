class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :phone, numericality: { only_integer: true, allow_blank: true }
  validates :mobile, numericality: { only_integer: true, allow_blank: true }
  validate :us_state

  before_validation do
    self.phone  = phone.gsub(/[^0-9]/, '') if attribute_present?('phone')
    self.mobile = mobile.gsub(/[^0-9]/, '') if attribute_present?('mobile')
  end

  scope :contacts_by_email, -> (email) { where(addressable_type: 'Contact').where('email ilike ANY (array[?])', email) }

  after_save do
    update_associated_search_documents if email_changed?
  end
  after_destroy :update_associated_search_documents

  def us_state
    if state.present?
      unless UsaState.new.abbreviations.include?(state)
        errors.add(:state, "has the wrong format")
      end
    end
  end

  def formatted_name
    name = ''
    name += ", #{city}" if city.present?
    name += ", #{state}" if state.present?
    name
  end

  def update_associated_search_documents
    if addressable_type == 'Contact'
      PgSearchDocumentUpdateWorker.perform_async('Contact', addressable_id)
    end
  end
end
