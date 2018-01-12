class Forecast::PmpRevenueCalcTriggerService
  def initialize(pmp, type, options)
    @pmp = pmp
    @company = pmp.company
    @type = type
    @options = options
  end

  def perform
    calculate(time_periods, users, products)
  end

  private

  attr_reader :type,
              :pmp,
              :options,
              :company

  def calculate(time_periods, users, products)
    time_periods.each do |time_period|
      users.each do |user|
        products.each do |product|
          Forecast::PmpRevenueCalcService.new(time_period, user, product).perform
        end
      end
    end
  end

  def start_date
    @_start_date ||= if type == 'date'
      options[:start_date]
    else
      pmp.start_date
    end
  end

  def end_date
    @_end_date ||= if type == 'date'
      options[:end_date]
    else
      pmp.end_date
    end
  end

  def products
    @_products ||= case type
    when 'product'
      options[:products]
    else
      pmp.products.distinct
    end
  end

  def users
    @_users ||= case type
    when 'user'
      options[:users]
    else
      pmp.users
    end
  end

  def time_periods
    @_time_periods ||= company.time_periods
      .for_time_period(start_date, end_date)
  end
end
