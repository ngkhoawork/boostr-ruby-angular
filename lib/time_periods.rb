class TimePeriods
  def initialize(date_range)
    @date_range = date_range
  end

  def months
    months = @date_range.map(&:beginning_of_month).uniq
    months.each_with_index do |month, index|
      if months.length == 1
        months = [@date_range]
      elsif index == 0
        months[index] = @date_range.first..month.end_of_month
      elsif index == months.length - 1
        months[index] = month.beginning_of_month..@date_range.last
      else
        months[index] = month.beginning_of_month..month.end_of_month
      end
    end
    months
  end

  def quarters
    quarters = @date_range.map(&:beginning_of_quarter).uniq
    quarters.each_with_index do |quarter, index|
      if quarters.length == 1
        quarters = [@date_range]
      elsif index == 0
        quarters[index] = @date_range.first..quarter.end_of_quarter
      elsif index == quarters.length - 1
        quarters[index] = quarter.beginning_of_quarter..@date_range.last
      else
        quarters[index] = quarter.beginning_of_quarter..quarter.end_of_quarter
      end
    end
    quarters
  end

  def time_period_names(period_type)
    names = []
    if period_type == 'qtr'
      quarters.each do |time_period|
        names << "Q#{quarter_month_numbers(time_period.first)}-#{time_period.first.year}"
      end
    else
      months.each do |time_period|
        names << time_period.first.strftime("%B")
      end
    end
    names
  end

  def all_time_periods_with_names
    quarters_with_names = []
    quarters.each_with_index do |quarter, index|
      quarters_with_names << {
        name: "Q#{quarter_month_numbers(quarter.first)}-#{quarter.first.year}",
        value: index + 1
      }
    end

    month_with_names = []
    months.each_with_index do |month, index|
      month_with_names << {
        name: "#{month.first.strftime("%B")} #{month.first.year}",
        value: index + 1
      }
    end

    {
      quarters: quarters_with_names,
      months: month_with_names
    }
  end

  private

  def quarter_month_numbers(date)
    1 + ((date.month-1)/3).to_i
  end
end
