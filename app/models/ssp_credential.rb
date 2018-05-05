class SspCredential < ActiveRecord::Base
  belongs_to :company
  belongs_to :ssp

  scope :filter_by, ->(company_ids, parser_type) { where(company_id: company_ids, parser_type: parser_type) }
  scope :parser_type, ->(parser_type) { where(parser_type: parser_type) }

  validates :key, presence: true
  validates :secret, presence: true, unless: ->(credential) { credential.ssp.adx? }
end
