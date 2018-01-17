class Lead < ActiveRecord::Base
  ACCEPTED = 'accepted'.freeze
  REJECTED = 'rejected'.freeze

  has_many :deals

  has_one :contact
  has_one :client

  belongs_to :company
  belongs_to :user

  scope :new_records, -> { where(status: nil) }
  scope :accepted, -> { where(status: ACCEPTED) }
  scope :rejected, -> { where(status: REJECTED) }
  scope :by_company_id, -> (company_id) { where(company_id: company_id) }

  after_create :match_contact

  def name
    first_name + last_name rescue first_name || last_name
  end

  private

  def match_contact
    self.update(contact: matched_contact) if matched_contact.present?
  end

  def matched_contact
    @_matched_contact ||=
      company.contacts.joins(:address).find_by(addresses: { email: email }) if company.present?
  end
end
