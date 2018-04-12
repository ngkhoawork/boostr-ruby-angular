class DatafeedCurrencyMapping < ActiveRecord::Base
  belongs_to :company

  validates_uniqueness_of :datafeed_curr_id, :curr_cd, scope: [:company_id]
end
