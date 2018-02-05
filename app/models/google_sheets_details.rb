class GoogleSheetsDetails < ActiveRecord::Base
  belongs_to :api_configuration

  validates_presence_of :sheet_id, allow_nil: false
end
