class ContactCf < ActiveRecord::Base
  belongs_to :company
  belongs_to :contact

  before_save :fetch_company_id_from_contact, on: :create

  private

  def fetch_company_id_from_contact
    self.company_id ||= contact&.company_id
  end
end
