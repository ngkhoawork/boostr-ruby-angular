module Csv
  class ActivitySummary::BaseDecorator
    def initialize(record, options = {})
      @record = record
      @options = options
    end

    def name
      record.name
    end

    def method_missing(name)
      type_name = name.to_s.titleize

      record.activities.for_time_period(start_date, end_date).where(activity_type_name: type_name).count
    end

    def total
      record.activities.for_time_period(start_date, end_date).count
    end

    private

    attr_reader :record, :options

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
end
