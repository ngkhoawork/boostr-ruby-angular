class AccountDimension < ActiveRecord::Base
  belongs_to :client
  belongs_to :holding_company

  has_many :account_pipeline_facts, dependent: :destroy
  has_many :account_revenue_facts, dependent: :destroy
  has_many :agencies, -> { uniq }, through: :agency_connections, source: :advertiser
  has_many :advertisers, -> { uniq }, through: :advertiser_connections, source: :agency
  has_many :agency_connections, class_name: :ClientConnection,
           foreign_key: :agency_id
  has_many :advertiser_connections, class_name: :ClientConnection,
           foreign_key: :advertiser_id
end
