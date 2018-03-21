class SspCredential < ActiveRecord::Base
  belongs_to :company

  scope :filter_by, ->(company_ids, parser_type) { where(company_id: company_ids, parser_type: parser_type) }
  scope :parser_type, ->(parser_type) { where(parser_type: parser_type) }
end
