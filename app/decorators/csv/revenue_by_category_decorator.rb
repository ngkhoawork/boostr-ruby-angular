class Csv::RevenueByCategoryDecorator
  def initialize(record)
    @record = record
    revenues_to_f!
  end

  def client_category_name
    @record.client_category_name
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
