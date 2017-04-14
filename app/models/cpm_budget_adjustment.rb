class CpmBudgetAdjustment < ActiveRecord::Base
  belongs_to :company
  belongs_to :dfp_api_configuration
end
