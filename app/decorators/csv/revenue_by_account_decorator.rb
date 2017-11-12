class Csv::RevenueByAccountDecorator
  def initialize(revenue_struct)
    @revenue_struct = revenue_struct
    revenues_to_f!
  end

  def name
    @revenue_struct.name
  end

  def category_id
    @revenue_struct.category_id
  end

  def client_region_id
    @revenue_struct.client_region_id
  end

  def client_segment_id
    @revenue_struct.client_segment_id
  end

  def team_name
    @revenue_struct.team_name
  end

  def seller_names
    @revenue_struct.seller_names
  end

  def year
    @revenue_struct.year.to_i
  end

  def revenues
    @revenue_struct.revenues
  end

  def total_revenue
    @revenue_struct.total_revenue.to_f
  end

  private

  def revenues_to_f!
    @revenue_struct.revenues.each { |k, v| @revenue_struct.revenues[k] = v.to_f  }
  end
end
