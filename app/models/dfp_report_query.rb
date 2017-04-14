class DfpReportQuery < ActiveRecord::Base
  enum report_type: [:cumulative, :monthly]

  belongs_to :api_configuration
end
