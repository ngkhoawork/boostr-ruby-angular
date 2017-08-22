class AccountDimension < ActiveRecord::Base
  enum account_type: { advertiser: 10, agency: 11 }

  belongs_to :client
  belongs_to :holding_company

  has_many :account_contacts, class_name: 'ClientContact', foreign_key: :client_id
  has_many :contacts, -> { uniq }, through: :account_contacts
  has_many :account_pipeline_facts, dependent: :destroy
  has_many :account_revenue_facts, dependent: :destroy
  has_many :agencies, -> { uniq }, through: :agency_connections, source: :advertiser
  has_many :advertisers, -> { uniq }, through: :advertiser_connections, source: :agency
  has_many :agency_connections, class_name: :ClientConnection,
           foreign_key: :agency_id
  has_many :advertiser_connections, class_name: :ClientConnection,
           foreign_key: :advertiser_id

  scope :agencies_by_holding_company_or_agency_id, Proc.new { |holding_company_id, account_id, company_id|
    AgencyByHoldingIdOrAgencyIdQuery.new(holding_company_id: holding_company_id, account_id: account_id, company_id: company_id).call
  }

  # CLASS METHODS
  class << self
    def related_advertisers_to_agencies(agency_ids)
      joins(:advertisers).where('client_connections.agency_id in (?)', agency_ids).distinct
    end
  end

end
