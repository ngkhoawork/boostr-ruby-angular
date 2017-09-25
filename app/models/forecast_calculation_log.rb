class ForecastCalculationLog < ActiveRecord::Base
  belongs_to :company

  validates :company_id, :start_date, presence: true

end
