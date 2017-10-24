class Csv::RevenueByCategoryDecorator
  def initialize(revenue_struct)
    @revenue_struct = revenue_struct
  end

  def category_id
    @revenue_struct.category_id
  end

  def year
    @revenue_struct.year.to_i
  end

  def revenues
    revenues_to_f!
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
