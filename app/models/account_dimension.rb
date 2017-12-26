class AccountDimension < ActiveRecord::Base
  enum account_type: { advertiser: 10, agency: 11 }

  belongs_to :client, foreign_key: :id
  belongs_to :holding_company
  belongs_to :company

  has_many :account_contacts, class_name: 'ClientContact', foreign_key: :client_id
  has_many :contacts, -> { uniq }, through: :account_contacts
  has_many :account_pipeline_facts, dependent: :destroy
  has_many :account_revenue_facts, dependent: :destroy
  has_many :agencies, -> { uniq }, through: :agency_connections, source: :advertiser
  has_many :advertisers, -> { uniq }, through: :advertiser_connections, source: :agency
  has_many :agency_connections, class_name: 'ClientConnection',
           foreign_key: :agency_id
  has_many :advertiser_connections, class_name: 'ClientConnection',
           foreign_key: :advertiser_id
  has_many :agency_revenue_facts, class_name: 'AdvertiserAgencyRevenueFact',
           foreign_key: :agency_id, dependent: :destroy
  has_many :advertiser_revenue_facts, class_name: 'AdvertiserAgencyRevenueFact',
           foreign_key: :advertiser_id, dependent: :destroy
  has_many :agency_pipeline_facts, class_name: 'AdvertiserAgencyPipelineFact',
           foreign_key: :agency_id, dependent: :destroy
  has_many :advertiser_pipeline_facts, class_name: 'AdvertiserAgencyPipelineFact',
           foreign_key: :advertiser_id, dependent: :destroy
  has_many :account_product_pipeline_facts, dependent: :destroy
  has_many :account_product_revenue_facts, dependent: :destroy


  scope :agencies_by_holding_company_or_agency_id, -> (holding_company_id, account_id, company_id) do
    AgencyByHoldingIdOrAgencyIdQuery.new(holding_company_id: holding_company_id,
                                         account_id: account_id,
                                         company_id: company_id).perform
  end

  scope :related_advertisers_to_agencies, -> (agency_ids) { joins(:advertisers).where('client_connections.agency_id in (?)', agency_ids).distinct }
  scope :related_advertisers_with_agency_in_io, -> { joins(:advertiser_revenue_facts).where('advertiser_agency_revenue_facts.agency_id IS NOT NULL') }

  scope :by_holding_company_id, -> (holding_company_id) { where(holding_company_id: holding_company_id) if holding_company_id }
  scope :by_company_id, ->(company_id) { where(company_id: company_id) }
  scope :by_account_type, ->(account_type) { where(account_type: account_type) }

end
