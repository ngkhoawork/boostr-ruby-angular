class CpmBudgetAdjustment < ActiveRecord::Base
  belongs_to :dfp_api_configuration

  validates_presence_of :percentage
end
