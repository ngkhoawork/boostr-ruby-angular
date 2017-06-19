module Csv
  class ActivitySummary::BaseService < BaseService
    private

    def headers
      activity_types_names.unshift('Name').push('Total')
    end

    def add_total_line_to(csv)
      line = ['Total']

      activity_types_names.each do |type|
        line << add_total_for(type)
      end

      line << total[:total]

      csv << line
    end

    def add_total_for(type)
      total[type].present? ? total[type] : 0
    end

    def activity_types_names
      company.activity_types.pluck(:name)
    end

    def company
      options.fetch(:company)
    end

    def start_date
      options.fetch(:start_date)
    end

    def end_date
      options.fetch(:end_date)
    end

    def total
      options.fetch(:total)
    end

    def add_total_line?
      true
    end
  end
end
