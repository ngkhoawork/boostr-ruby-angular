class Csv::ActivitySummaryDecorator
  def initialize(user, options = {})
    @user = user
    @options = options
  end

  def name
    user.name 
  end

  def method_missing(name)
    type_name = name.to_s.titleize

    user.activities.for_time_period(start_date, end_date).where(activity_type_name: type_name).count
  end

  def total
    user.activities.for_time_period(start_date, end_date).count
  end

  private

  attr_reader :user, :options

  def company
    @_company ||= options.fetch(:company)
  end

  def activity_types_names
    company.activity_types.pluck(:name)
  end

  def start_date
    @_start_date ||= options.fetch(:start_date)
  end

  def end_date
    @_end_date ||= options.fetch(:end_date)
  end
end
