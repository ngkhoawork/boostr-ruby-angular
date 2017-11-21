class Csv::RevenueByAccountDecorator
  def initialize(record)
    @record = record
    revenues_to_f!
  end

  def name
    @record.name
  end

  def client_category_name
    @record.client_category_name
  end

  def client_region_name
    @record.client_region_name
  end

  def client_segment_name
    @record.client_segment_name
  end

  def team_name
    @record.client.primary_user&.team&.name
  end

  def seller_names
    @record.client.primary_user&.name
  end

  def year
    @record.year.to_i
  end

  def month_revenues
    @record.month_revenues
  end

  def total_revenue
    @record.total_revenue.to_f
  end

  private

  def revenues_to_f!
    @record.month_revenues.each { |k, v| @record.month_revenues[k] = v.to_f  }
  end
end
