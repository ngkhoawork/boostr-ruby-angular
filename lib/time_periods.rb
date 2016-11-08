class TimePeriods
  def months(date_range)
    months = date_range.map(&:beginning_of_month).uniq
    months.each_with_index do |quarter, index|
      if months.length == 1
        months = [date_range]
      elsif index == 0
        months[index] = date_range.first..quarter.end_of_month
      elsif index == months.length - 1
        months[index] = quarter.beginning_of_month..date_range.last
      else
        months[index] = quarter.beginning_of_month..quarter.end_of_month
      end
    end
    months
  end

  def quarters(date_range)
    quarters = date_range.map(&:beginning_of_quarter).uniq
    quarters.each_with_index do |quarter, index|
      if quarters.length == 1
        quarters = [date_range]
      elsif index == 0
        quarters[index] = date_range.first..quarter.end_of_quarter
      elsif index == quarters.length - 1
        quarters[index] = quarter.beginning_of_quarter..date_range.last
      else
        quarters[index] = quarter.beginning_of_quarter..quarter.end_of_quarter
      end
    end
    quarters
  end
end