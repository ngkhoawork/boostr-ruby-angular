class Csv::ActivitySummaryService < Csv::BaseService
  private

  def generate_csv
    CSV.generate do |csv|
      csv << headers

      decorated_records.each do |record|
        csv << headers.map { |attr| record.send(attr.downcase) }
      end
      
      add_total_line_to(csv)
    end
  end

  def add_total_line_to(csv)
    line = ['Total']

    activity_types_names.each do |type|
      line << activities_count_by_type(type)
    end

    line << all_activities_count

    csv << line
  end

  def decorated_records
    records.map { |record| Csv::ActivitySummaryDecorator.new(record, options) }
  end

  def headers
    activity_types_names.unshift('Name').push('Total')
  end

  def company
    options.fetch(:company)
  end

  def activity_types_names
    company.activity_types.pluck(:name)
  end

  def start_date
    options.fetch(:start_date)
  end

  def end_date
    options.fetch(:end_date)
  end
  
  def record_ids
    @_record_ids ||= records.map(&:id)
  end
  
  def activities_count_by_type(type)
    company.activities
      .for_time_period(start_date, end_date)
      .by_user(record_ids)
      .where(activity_type_name: type)
      .count
  end
  
  def all_activities_count
    company.activities.for_time_period(start_date, end_date).by_user(record_ids).count
  end
end
