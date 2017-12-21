class Csv::QuotaAttainmentDecorator
  def initialize(row, company)
    @row = row
    @company = company
  end

  def name
    row[:name]    
  end

  def team
    row[:team][:name] rescue ''
  end

  def quota
    ActiveSupport::NumberHelper.number_to_currency(row[:quota], precision: 0, unit: '$')
  end

  def revenue
    ActiveSupport::NumberHelper.number_to_currency(row[:revenue], precision: 0, unit: '$')
  end

  def pipeline_w
    ActiveSupport::NumberHelper.number_to_currency(row[:weighted_pipeline], precision: 0, unit: '$')
  end

  def forecast_amt
    ActiveSupport::NumberHelper.number_to_currency(row[:amount], precision: 0, unit: '$')
  end

  def gap_to_quota
    ActiveSupport::NumberHelper.number_to_currency(row[:gap_to_quota], precision: 0, unit: '$')
  end

  def percent_to_quota
    ActiveSupport::NumberHelper.number_to_percentage(row[:percent_to_quota], precision: 0)
  end

  def percent_booked
    ActiveSupport::NumberHelper.number_to_percentage(row[:percent_booked], precision: 0)
  end

  def is_leader?
    row[:is_leader]
  end

  private

  attr_reader :row, :company
end