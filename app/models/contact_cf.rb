class ContactCf < ActiveRecord::Base
  include HasValidationsOnPercentageCfs

  belongs_to :company
  belongs_to :contact

  before_save :fetch_company_id_from_contact, on: :create

  def contact_cf_names
    @contact_cf_names ||= contact&.company&.contact_cf_names || ContactCfName.none
  end

  private

  def self.custom_field_names_assoc
    :contact_cf_names
  end

  def fetch_company_id_from_contact
    self.company_id ||= contact&.company_id
  end
end
